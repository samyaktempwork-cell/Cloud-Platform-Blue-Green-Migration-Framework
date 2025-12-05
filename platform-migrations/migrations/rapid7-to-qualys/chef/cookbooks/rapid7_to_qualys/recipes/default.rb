#
# default.rb - primary entrypoint for role run_list
#
include_recipe 'rapid7_to_qualys::logging'
include_recipe 'rapid7_to_qualys::remove_rapid7'
include_recipe 'rapid7_to_qualys::install_qualys'
include_recipe 'rapid7_to_qualys::validate'
