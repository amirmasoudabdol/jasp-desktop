macro(patch_r r_pkg_r_home)

  message(STATUS ${r_pkg_r_home}/bin)

  execute_process(WORKING_DIRECTORY ${r_pkg_r_home}/bin
                  COMMAND sed -i.bak -e "s/R_HOME_DIR=.*/R_HOME_DIR=$(pwd)/g" R)

  execute_process(
    WORKING_DIRECTORY ${r_pkg_r_home}/bin
    COMMAND sed -i.bak -e "s/R_SHARE_DIR=.*/R_SHARE_DIR=$(pwd)\\/share/g" R)

  execute_process(
    WORKING_DIRECTORY ${r_pkg_r_home}/bin
    COMMAND sed -i.bak -e "s/R_INCLUDE_DIR=.*/R_INCLUDE_DIR=$(pwd)\\/include/g"
            R)

  execute_process(
    WORKING_DIRECTORY ${r_pkg_r_home}/bin
    COMMAND sed -i.bak -e "s/R_DOC_DIR=.*/R_DOC_DIR=$(pwd)\\/doc/g" R)

  execute_process(
    WORKING_DIRECTORY ${r_pkg_r_home}/etc
    COMMAND
      sed -i.bak -e
      "s/LIBR =.*/LIBR = -F$(R_HOME)\\/..\\/..\\/..\\/..\\/ -framework R/g"
      Makeconf)

endmacro()
