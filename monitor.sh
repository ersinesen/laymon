#!/bin/bash
#
# Start monitoring
#
# EE May '24

# Parameters
export WEBDIR=./web
export DISPLAY=:99
SESSION=laymon
SCREENSHOT="${WEBDIR}/screenshot.jpg"

# Function to handle cleanup on CTRL-C
cleanup() {
    echo "Script interrupted. Exiting..."
    
    kill $TERMINAL_PID
    kill $XVFB_PID
    kill $WEBSERVER_PID

    tmux kill-session -t $SESSION

    exit 0
}

# Trap SIGINT (CTRL-C) and call the cleanup function
trap cleanup SIGINT

# Start Xvfb on display :99
Xvfb $DISPLAY -screen 0 1536x864x24 &
XVFB_PID=$!

# Wait a bit to ensure Xvfb is fully started
sleep 2

# Run a shell command within the virtual display, example using xterm
xterm -bg '#000000' -maximized -fa 'Monospace' -fs 12 -geometry 192x54 -e "tmux new -s $SESSION" &
TERMINAL_PID=$!
sleep 1

# Split the window vertically (10% height for the top pane)
tmux split-window -t $SESSION -v -p 90

# Split the bottom window horizontally
tmux split-window -t $SESSION:0.1 -h -p 50

# Send the command to the first pane (top pane)
#tmux send-keys -t $SESSION:0.0 'PS1="" && echo -e "\e[44m" && python3 title.py' C-m
tmux send-keys -t $SESSION:0.0 'PS1="" && echo -e "\e[34m" && echo "Hostname:" `hostname` && lsb_release -d && uname -a' C-m

# Send the command to the second pane (bottom left pane)
tmux send-keys -t $SESSION:0.1 'btop/bin/btop -p 1' C-m

# Send the command to the second pane (bottom left pane)
tmux send-keys -t $SESSION:0.2 'btop/bin/btop -p 2' C-m

# Wait for the command to render in the virtual display
sleep 2

# Start Web server
python3 serve.py $SCREENSHOT &
#python -m http.server --directory $WEBDIR 3000 &
WEBSERVER_PID=$!

# Infinite loop to run the command every second
while true; do

  # Capture the screen using xwd
  xwd -root -display $DISPLAY | convert xwd:- -quality 90 $SCREENSHOT

  # Sleep for 1 second
  sleep 1

done
