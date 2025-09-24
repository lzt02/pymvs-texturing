// #include <pybind11/pybind11.h>
// #include <pybind11/stl.h>

// // mvs-texturing 的核心接口
// #include "tex/texturing.h"

// namespace py = pybind11;

// PYBIND11_MODULE(pymvs_texturing, m) {
//     m.doc() = "Python bindings for MVS-Texturing (texrecon)";

//     m.def("texrecon", [](const std::string& mesh,
//                          const std::string& scene,
//                          const std::string& out_prefix) {
//         texturing::Settings settings;
//         texturing::run(mesh, scene, out_prefix, settings);
//     }, R"pbdoc(
//         Run the texrecon pipeline.

//         Args:
//             mesh (str): 输入 mesh 路径 (e.g. "mesh-clean.ply")
//             scene (str): MVS 场景路径 (e.g. "scene.mvs")
//             out_prefix (str): 输出文件前缀 (e.g. "output/tex")

//         Example:
//             import pymvs_texturing
//             pymvs_texturing.texrecon("mesh.ply", "scene.mvs", "output/tex")
//     )pbdoc");
// }

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <pybind11/numpy.h>
using namespace pybind11::literals;

// 必须先包含标准头，再含 mve/tex 头
#include <mve/mesh.h>
#include <mve/mesh_io_ply.h>
#include "tex/texturing.h"
#include "tex/settings.h"

namespace py = pybind11;
using namespace tex;   // 方便写，也可显式 tex::XXX

// 把原来 texrecon.cpp 的 main 里核心步骤封装成一个函数
void texrecon(const std::string &scene_file,
              const std::string &mesh_file,
              const std::string &out_prefix,
              int  num_threads = 0)
{
    /* ---------- 1. 基本检查 ---------- */
    std::string const out_dir = util::fs::dirname(out_prefix);
    if (!util::fs::dir_exists(out_dir.c_str()))
        throw std::invalid_argument("Destination directory does not exist!");

    /* ---------- 2. Settings 用默认 ---------- */
    Settings settings;          // 现在正确命名空间：tex::Settings

    /* ---------- 3. 加载 mesh ---------- */
    mve::TriangleMesh::Ptr mesh = mve::geom::load_ply_mesh(mesh_file);
    mve::MeshInfo mesh_info(mesh);
    prepare_mesh(&mesh_info, mesh);

    /* ---------- 4. 生成 texture views ---------- */
    TextureViews views;
    std::string tmp_dir = util::fs::join_path(out_dir, "tmp");
    if (!util::fs::dir_exists(tmp_dir.c_str()))
        util::fs::mkdir(tmp_dir.c_str());
    generate_texture_views(scene_file, &views, tmp_dir);

    /* ---------- 5. 建图 + 视选 ---------- */
    std::size_t num_faces = mesh->get_faces().size() / 3;
    UniGraph graph(num_faces);
    build_adjacency_graph(mesh, mesh_info, &graph);

    DataCosts data_costs(num_faces, views.size());
    calculate_data_costs(mesh, &views, settings, &data_costs);
    view_selection(data_costs, &graph, settings);

    /* ---------- 6. 生成贴图 ---------- */
    VertexProjectionInfos vpi;
    TexturePatches patches;
    generate_texture_patches(graph, mesh, mesh_info, &views,
                             settings, &vpi, &patches);

    if (settings.global_seam_leveling)
        global_seam_leveling(graph, mesh, mesh_info, vpi, &patches);
    if (settings.local_seam_leveling)
        local_seam_leveling(graph, mesh, vpi, &patches);

    TextureAtlases atlases;
    generate_texture_atlases(&patches, settings, &atlases);

    /* ---------- 7. 输出 obj + 材质 ---------- */
    Model model;
    build_model(mesh, atlases, &model);
    Model::save(model, out_prefix);

    /* ---------- 8. 清临时目录 ---------- */
    for (auto &f : util::fs::Directory(tmp_dir))
        util::fs::unlink(util::fs::join_path(tmp_dir, f.name).c_str());
    util::fs::rmdir(tmp_dir.c_str());
}

// 绑定到 Python
PYBIND11_MODULE(pymvs_texturing, m)
{
    m.doc() = "Python bindings for MVS-Texturing (texrecon core)";
    m.def("texrecon", &texrecon,
          "mesh_file"_a, "scene_file"_a, "out_prefix"_a, "num_threads"_a = 0,
          R"pbdoc(
            Run full texrecon pipeline.
            Args:
                mesh_file:   input ply path
                scene_file:  MVS scene file
                out_prefix:  output path prefix (no extension)
                num_threads: 0 = auto
          )pbdoc");
}