
#include <SDL.h>
#include <SDL_opengles2.h>

#include <emscripten.h>

SDL_Window *window;

SDL_Event event;

void main_loop()
{
    /* Check for events */
    while(SDL_PollEvent(&event))
    {
        if(event.type == SDL_QUIT || event.type == SDL_KEYDOWN || event.type == SDL_FINGERDOWN)
        {
            exit(0);
        }
    }

    // as we don't have a timer we need to do something here
    // using a static to update at an interval
    static int t=0;
    if(++t > 100)
    {
        float r=(double)rand() / ((double)RAND_MAX + 1);
        float g=(double)rand() / ((double)RAND_MAX + 1);
        float b=(double)rand() / ((double)RAND_MAX + 1);

        glClearColor(r,g,b,1);
        t=0;
    }
    glClear(GL_COLOR_BUFFER_BIT);
    // this is where we draw
    SDL_GL_SwapWindow(window);
}

int main(int argc, char *argv[])
{
    SDL_Init(SDL_INIT_VIDEO);

    SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);

    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4);

    window = SDL_CreateWindow(
        "Test",                       // window title
        SDL_WINDOWPOS_UNDEFINED,           // initial x position
        SDL_WINDOWPOS_UNDEFINED,           // initial y position
        800,                               // width, in pixels
        600,                               // height, in pixels
        SDL_WINDOW_OPENGL | SDL_RENDERER_PRESENTVSYNC | SDL_WINDOW_RESIZABLE
    );

    // Init GL
    SDL_GLContext glcontext = SDL_GL_CreateContext(window);

    emscripten_set_main_loop(main_loop, 0, false);

    return 0;
}
