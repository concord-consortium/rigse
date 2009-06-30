class Admin::VendorInterfacesController < ApplicationController
  layout "admin"
  active_scaffold :vendor_interface
end