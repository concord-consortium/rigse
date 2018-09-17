require 'spec_helper'

describe CommonsLicensePolicy do
  subject                 { CommonsLicensePolicy.new(active_user, commons_license) }
  let(:active_user)       { nil                                                    }
  let(:commons_license)   { FactoryBot.create(:commons_license)                   }

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
    let(:active_user) { FactoryBot.create(:user) }

    it { is_expected.not_to permit(:index)   }
    it { is_expected.not_to permit(:show)    }
    it { is_expected.not_to permit(:new)     }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:destroy) }
  end

  context "for an admin" do
    let(:active_user) { FactoryBot.generate(:admin_user)   }

    it { is_expected.to permit(:index)   }
    it { is_expected.to permit(:show)    }
    it { is_expected.to permit(:new)     }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:destroy) }
  end

  context "for a manager" do
    let(:active_user) { FactoryBot.create(:user) }
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


  # TODO: auto-generated
  describe '#index?' do
    it 'index?' do
      commons_license_policy = described_class.new(nil, nil)
      result = commons_license_policy.index?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      commons_license_policy = described_class.new(nil, nil)
      result = commons_license_policy.show?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new_or_create?' do
    it 'new_or_create?' do
      commons_license_policy = described_class.new(nil, nil)
      result = commons_license_policy.new_or_create?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_edit_or_destroy?' do
    it 'update_edit_or_destroy?' do
      commons_license_policy = described_class.new(nil, nil)
      result = commons_license_policy.update_edit_or_destroy?

      expect(result).to be_nil
    end
  end


end
