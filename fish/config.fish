set -g -x PATH /usr/local/bin $PATH
 
# Add node directories
#set PATH /home/filip/.nvm $PATH

# ADD go directories
# set PATH /home/filip/go/bin $PATH

# Add Java directories
set -x JAVA_HOME (jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')

# Add Android directories
# set -x ANDROID_HOME=/home/filip/Android/Sdk
# set PATH /home/filip/Android/Sdk/tools $PATH
# set PATH /home/filip/Android/Sdk/platform-tools $PATH
set --export ANDROID $HOME/Android;
set --export ANDROID_HOME $ANDROID/Sdk;
set --export ANDROID_NDK $ANDROID/android-ndk-r17c
set -gx PATH $ANDROID_HOME/tools $PATH;
set -gx PATH $ANDROID_HOME/tools/bin $PATH;
set -gx PATH $ANDROID_HOME/platform-tools $PATH;
set -gx PATH $ANDROID_HOME/emulator $PATH

set -g -x fish_greeting ''

set -g theme_color_scheme zenburn

# Auto-launching ssh-agent in fish shell
setenv SSH_ENV $HOME/.ssh/environment

function start_agent                                                                                                                                                                    
    echo "Initializing new SSH agent ..."
    ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
    echo "succeeded"
    chmod 600 $SSH_ENV 
    . $SSH_ENV > /dev/null
    ssh-add
end

function test_identities                                                                                                                                                                
    ssh-add -l | grep "The agent has no identities" > /dev/null
    if [ $status -eq 0 ]
        ssh-add
        if [ $status -eq 2 ]
            start_agent
        end
    end
end

if [ -n "$SSH_AGENT_PID" ] 
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
    if [ $status -eq 0 ]
        test_identities
    end  
else
    if [ -f $SSH_ENV ]
        . $SSH_ENV > /dev/null
    end  
    ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
    if [ $status -eq 0 ]
        test_identities
    else 
        start_agent
    end  
end
