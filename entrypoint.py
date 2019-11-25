#!/usr/bin/python3

#from entrypoint_helpers import env, gen_cfg, gen_container_id, start_app


RUN_USER = env['run_user']
RUN_GROUP = env['run_group']
CROWD_INSTALL_DIR = env['crowd_install_dir']
CROWD_HOME = env['crowd_home']

gen_cfg('server.xml.j2', f'{CROWD_INSTALL_DIR}/apache-tomcat/conf/server.xml')
# gen_cfg('container_id.j2', '/etc/container_id')
# gen_cfg('dbconfig.xml.j2', f'{CROWD_HOME}/dbconfig.xml',
#         user=RUN_USER, group=RUN_GROUP, overwrite=False)
# gen_cfg('cluster.properties.j2', f'{CROWD_HOME}/cluster.properties',
#         user=RUN_USER, group=RUN_GROUP, overwrite=False)

start_app(f'{CROWD_INSTALL_DIR}/start_crowd.sh -fg', CROWD_HOME, name='crowd')
