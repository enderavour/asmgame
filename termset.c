#include <termios.h>
#include <unistd.h>

static struct termios orig_state;
static struct termios game_state;

void set_term_game_state()
{
    tcgetattr(STDIN_FILENO, &orig_state);
    game_state = orig_state;

    game_state.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &game_state);
}

void restore_term_state()
{
    tcsetattr(STDIN_FILENO, TCSANOW, &orig_state);
}
