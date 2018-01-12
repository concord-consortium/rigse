require 'spec_helper'

describe CommonsLicensePolicy do
  subject                 { CommonsLicensePolicy.new(active_user, commons_license) }
  let(:active_user)       { nil                                                    }
  let(:commons_license)   { FactoryGirl.create(:commons_license)                   }

  context "for anonymous" do
    it { should_not permit(:index)   }
    it { should_not permit(:show)    }
    it { should_not permit(:new)     }
    it { should_not permit(:edit)    }
    it { should_not permit(:create)  }
    it { should_not permit(:update)  }
    it { should_not permit(:destroy) }
  end

  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }

    it { should_not permit(:index)   }
    it { should_not permit(:show)    }
    it { should_not permit(:new)     }
    it { should_not permit(:edit)    }
    it { should_not permit(:create)  }
    it { should_not permit(:update)  }
    it { should_not permit(:destroy) }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }

    it { should permit(:index)   }
    it { should permit(:show)    }
    it { should permit(:new)     }
    it { should permit(:edit)    }
    it { should permit(:create)  }
    it { should permit(:update)  }
    it { should permit(:destroy) }
  end

  context "for a manager" do
    let(:active_user) { FactoryGirl.create(:user) }
    before(:each) do
      active_user.add_role('manager')
    end
    it { should permit(:index)   }
    it { should permit(:show)    }
    it { should permit(:new)     }
    it { should permit(:edit)    }
    it { should permit(:create)  }
    it { should permit(:update)  }
    it { should permit(:destroy) }
  end

end