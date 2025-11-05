#!/bin/bash



# ideas for future, for now i just got hash checks done
# args - default_config_branch, civ_core_branch, spec_branch
# for each of them, we can have presets, so rather than default-config-base
# we can just put in base and it replaces it as it needs
# but if it is null or some other thing that means nothing, it will use whatever the default is
# most of this is kinda of done, but also kinda of not

updateConfig=${1:-"dev"}

if [ $updateConfig -eq 1 ]; then
  updateConfig="main"
fi

if [ "$updateConfig" != "null" ]; then
  branchData=$(curl -Ls https://api.github.com/repos/Emergent-Civilization/Neolithic/branches/$updateConfig)

  branchExistsMsg=$(echo $branchData | jq -r .message)
  if [ "$branchExistsMsg" == "Branch not found" ]; then
    echo "Neolithic branch '$updateConfig' does not exist"
    echo "not updating config"
  else
    echo "Updating Config"
    if [ -e default-config.hash ]; then
      currentHash=$(cat default-config.hash)
    else
      currentHash=""
    fi
    echo "Current Hash : $currentHash"
    newHash=$(curl -Ls https://api.github.com/repos/Emergent-Civilization/Neolithic/branches/$updateConfig | jq -r .commit.sha)
    echo "New Hash     : $newHash"
    if [ "$currentHash" != "$newHash" ]; then
      echo "Hashes different, downloading most recent commit on branch $updateConfig"
      rm -rf Emergent-Civilization-default-server-config-$newHash default-config.zip
      curl -L -o default-config.zip https://api.github.com/repos/Emergent-Civilization/default-server-config/zipball/$updateConfig && \
      unzip default-config.zip  && \
      cp -r Emergent-Civilization-default-server-config-$newHash/* . && \
      cp -r Emergent-Civilization-default-server-config-$newHash/.[^.]* . 2>/dev/null || true && \ 
      rm -rf Emergent-Civilization-default-server-config-$newHash default-config.zip default-config.hash
      echo $newHash > default-config.hash
    else
      echo "Hashes same, doing nothing"
    fi
  fi
fi


java -Xms16G -Xmx16G -XX:+UseZGC -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -Dterminal.jline=false -Dterminal.ansi=true -jar server.jar
