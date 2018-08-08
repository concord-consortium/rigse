require 'spec_helper'

describe CommonsLicensePolicy do
  subject                 { CommonsLicensePolicy.new(active_user, commons_license) }
  let(:active_user)       { nil                                                    }
  let(:commons_license)   { FactoryGirl.create(:commons_license)                   }

  context "for anonymous" do
    it { is_expected.not_to permit(:index)   }
    it { is_expected.not_to permit(:show)    }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:destroy) }
  end

  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }

    it { is_expected.not_to permit(:index)   }
    it { is_expected.not_to permit(:show)    }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:destroy) }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }

    it { is_expected.to permit(:index)   }
    it { is_expected.to permit(:show)    }
    it { is_expected.to permit(:new)     }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:destroy) }
  end

  context "for a manager" do
    let(:active_user) { FactoryGirl.create(:user) }
    before(:each) do
      active_user.add_role('manager')
    end
    it { is_expected.to permit(:index)   }
    it { is_expected.to permit(:show)    }
    it { is_expected.to permit(:new)     }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:destroy) }
  end

end