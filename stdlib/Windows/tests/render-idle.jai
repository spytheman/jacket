// test: only(.WINDOWS)
#import "Basic";
W :: #import "Windows";
WC :: #import "Window_Creation";
S :: #import "Simp";
I :: #import "Input";
GL :: #import "GL";

main :: () {
    window := WC.create_window(1280, 720, "Idle WGL rendering regression");
    assert(window != null);
    defer assert(W.DestroyWindow(window) != 0);
    S.prepare_window(window, 0);
    S.set_render_target(window);
    native := W.wglGetCurrentContext();
    dc := W.wglGetCurrentDC();
    for 0..5999 {
        I.update_window_events();
        S.set_render_target(window);
        assert(W.wglGetCurrentContext() == native && W.wglGetCurrentDC() == dc);
        S.clear_render_target(0, 1, 0, 1);
        S.set_shader_for_color();
        S.immediate_begin();
        S.immediate_quad(0, 0, 32, 32, .{ 0, 1, 0, 1 });
        S.swap_buffers(window, false);
        reset_temporary_storage();
    }
    S.clear_render_target(0, 1, 0, 1);
    pixel: [4] u8;
    GL.gl.glReadPixels(4, 4, 1, 1, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, pixel.data);
    assert(GL.gl.glGetError() == GL.GL_NO_ERROR);
    assert(pixel[0] == 0 && pixel[1] == 255 && pixel[2] == 0 && pixel[3] == 255);
    print("ok\n");
}
