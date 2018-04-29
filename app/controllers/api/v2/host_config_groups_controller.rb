module Api
  module V2
    class HostConfigGroupsController < V2::BaseController
      include Api::Version2

      before_action :find_host, :only => [:index, :create, :destroy]
      before_action :find_config_group, :only => [:create, :destroy]

      api :GET, "/hosts/:host_id/config_group_ids/", N_("List all Config group IDs for host")

      def index
        render :json => { root_node_name => HostConfigGroup.authorized(:edit_host_config_groups).where(:host_id => @host.id).pluck('config_group_id') }
      end

      api :POST, "/hosts/:host_id/config_group_ids", N_("Add a Puppet class to host")
      param :host_id, String, :required => true, :desc => N_("ID or Name of host")
      param :config_group_id, String, :required => true, :desc => N_("ID or Name of Config Group")

      def create
        @host_config_group = HostConfigGroup.create!(:host_id => @host.id, :config_group_id => @config_group.id, :host_type => "Host::Base")
        render :json => {:host_id => @host_config_group.host_id, :config_group_id => @host_config_group.config_group_id}
      end

      api :DELETE, "/hosts/:host_id/config_group_ids/:id/", N_("Remove a Config Group from host")
      param :host_id, String, :required => true, :desc => N_("ID of host")
      param :id, String, :required => true, :desc => N_("ID or Name of Config Group")

      def destroy
        @host_config_group = HostConfigGroup.authorized(:edit_host_config_group).where(:host_id => @host.id, :config_group_id => @config_group.id)
        process_response @host_config_group.destroy_all
      end

      private

      # overwrite resource_name so it's host and and not host_class, since we want to return @host
      def find_host
        if params[:host_id].blank?
          not_found
          return false
        end
        if Host::Managed.respond_to?(:authorized) &&
          Host::Managed.authorized("view_host", Host::Managed)
          @host = resource_finder(Host.authorized(:view_hosts), params[:host_id])
        end
      end

      def find_config_group
        if params[:action] == 'create'
          cfg_group_id = params[:config_group_id]
        else
          cfg_group_id = params[:id]
        end
        @config_group = resource_finder(ConfigGroup.authorized(:view_config_groups), cfg_group_id)
      end
    end
  end
end
