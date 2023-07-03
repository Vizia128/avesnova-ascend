using ModernGL, GLFW, GeometryTypes
import GLAbstraction as GLA
include("shader_manager.jl")
include("uniforms.jl")

function create_window()
    # Create the window. This sets all the hints and makes the context current.
    window = GLFW.Window(name="Aves Ascention", resolution=(800,600))
    GLFW.MakeContextCurrent(window)
    GLA.set_context!(window)
    return window
end

function create_gla_program()
    vertex_shader = get_vertex_shader()
    fragment_shader = get_fragment_shader()
    gla_program = GLA.Program(vertex_shader, fragment_shader)
    return gla_program
end

function get_default_vertices()
    # The positions of the vertices in our rectangle
    vertex_positions = PointPGA{2,Float32}[(-1.0,  1.0),     # top-left
                                        ( 1.0,  1.0),     # top-right
                                        ( 1.0, -1.0),     # bottom-right
                                        (-1.0, -1.0)]     # bottom-left

    elements = Face{3,UInt32}[(0,1,2),          # the first triangle
                              (2,3,0)]          # the second triangle

    return vertex_positions, elements
end

struct RenderingManager
    window::GLFW.Window
    gla_program::GLA.Program
    vertex_array_obj::GLA.VertexArray
end

function RenderingManager()
    window = create_window()
    gla_program = create_gla_program()
    vertex_positions, elements = get_default_vertices()
    buffers = GLA.generate_buffers(gla_program, GLA.GEOMETRY_DIVISOR; position = vertex_positions)
    vertex_array_obj = GLA.VertexArray(buffers, elements)
    return RenderingManager(window, gla_program, vertex_array_obj)
end

function render(rendering_manager::RenderingManager, game_state::GameState)
    glClear(GL_COLOR_BUFFER_BIT)
    GLA.bind(rendering_manager.gla_program)

    # put uniforms and buffers here
    tex::Vector{Float32} = [1.0, 0.0, (cos(time()) + 1) / 2, 1.0]
    u = GLA.uniform_location(rendering_manager.gla_program, :tex)
    if u != GLA.INVALID_UNIFORM
        glUniform4f(u, tex...)
    end

    test_buffer::Vector{Float32} = []
    # test_buffer[2] = (sin(time()) + 1) / 2
    # test_buffer[15] = (sin(time()) + 1) / 2
    set_shader_storage_block(rendering_manager.gla_program, "ObjectBuffer", test_buffer)

    GLA.bind(rendering_manager.vertex_array_obj)
    GLA.draw(rendering_manager.vertex_array_obj)
    GLA.unbind(rendering_manager.vertex_array_obj)
    GLA.unbind(rendering_manager.gla_program)
    GLFW.SwapBuffers(rendering_manager.window)
end

function should_exit(rendering_manager::RenderingManager)
    return GLFW.WindowShouldClose(rendering_manager.window) || GLFW.GetKey(rendering_manager.window, GLFW.KEY_ESCAPE) == GLFW.PRESS
end

function cleanup(rendering_manager::RenderingManager)
    GLFW.SetWindowShouldClose(rendering_manager.window, true)
end
