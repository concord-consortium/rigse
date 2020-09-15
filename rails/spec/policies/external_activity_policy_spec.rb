require 'spec_helper'

describe ExternalActivityPolicy do
  subject                 { ExternalActivityPolicy.new(active_user, activity)   }
  let(:active_user)       { nil                                                 }
  let(:activity)          { FactoryBot.create(:external_activity)              }

  context "for anonymous" do
    it { is_expected.to permit(:preview_index)           }
    it { is_expected.not_to permit(:publish)             }
    it { is_expected.not_to permit(:duplicate)           }
    it { is_expected.not_to permit(:matedit)             }
    it { is_expected.not_to permit(:duplicate)           }
    it { is_expected.not_to permit(:copy)                }
    it { is_expected.not_to permit(:update_basic)        }
    it { is_expected.not_to permit(:update)              }
    it { is_expected.not_to permit(:archive)             }
    it { is_expected.not_to permit(:unarchive)           }
    it { is_expected.not_to permit(:edit_credits)        }
  end


  context "for a normal user" do
    let(:active_user) { FactoryBot.create(:user) }

    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.not_to permit(:publish)              }
    it { is_expected.not_to permit(:duplicate)            }
    it { is_expected.not_to permit(:matedit)              }
    it { is_expected.not_to permit(:duplicate)            }
    it { is_expected.not_to permit(:update_basic)         }
    it { is_expected.not_to permit(:update)               }
    it { is_expected.not_to permit(:archive)              }
    it { is_expected.not_to permit(:unarchive)            }
    it { is_expected.not_to permit(:edit_credits)         }
  end

  context "for the owner" do
    let(:email)      { 'foo@robots.gov' }
    let(:active_user){ FactoryBot.create(:user, email: email) }
    let(:activity)   { FactoryBot.create(:external_activity, user: active_user, author_email: email)  }
    before(:each) do
      active_user.add_role('author')
    end

    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.to permit(:publish)                  }
    it { is_expected.to permit(:matedit)                  }
    it { is_expected.to permit(:update_basic)             }
    it { is_expected.to permit(:archive)                  }
    it { is_expected.to permit(:unarchive)                }

    # not sure why. Just documenting:
    it { is_expected.not_to permit(:duplicate)            }

    it { is_expected.not_to permit(:edit_credits)         }
  end

  context "for an admin" do
    let(:active_user) { FactoryBot.generate(:admin_user)   }

    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.to permit(:publish)                  }
    it { is_expected.to permit(:matedit)                  }
    it { is_expected.to permit(:update_basic)             }
    it { is_expected.to permit(:archive)                  }
    it { is_expected.to permit(:unarchive)                }
    it { is_expected.to permit(:duplicate)                }
    it { is_expected.to permit(:edit_credits)             }
  end


  context "for a material admin" do
    let(:project_a)   { FactoryBot.create(:project)                                 }
    let(:active_user) { FactoryBot.create(:user, admin_for_projects: [project_a])   }
    let(:activity)    { FactoryBot.create(:external_activity, projects: [project_a])}
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
    end
    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.to permit(:publish)                  }
    it { is_expected.to permit(:matedit)                  }
    it { is_expected.to permit(:update_basic)             }
    it { is_expected.to permit(:archive)                  }
    it { is_expected.to permit(:unarchive)                }
    it { is_expected.to permit(:duplicate)                }
    it { is_expected.to permit(:edit_credits)             }
  end

  context "for an admin of a project that is not one of the material's projects" do
    let(:project_a)   { FactoryBot.create(:project)                                 }
    let(:active_user) { FactoryBot.create(:user, admin_for_projects: [project_a])   }
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
    end
    it { is_expected.to permit(:edit_projects)            }
    it { is_expected.to permit(:edit_cohorts)             }
    it { is_expected.to permit(:edit)                     }
    # this type of user needs to be able to update the activity so that it can make a
    # material part of a project that isn't already part of the project.
    it { is_expected.to permit(:update)                   }
  end


  # TODO: auto-generated
  describe '#preview_index?' do
    it 'preview_index?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.preview_index?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#publish?' do
    it 'publish?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.publish?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#republish?' do
    xit 'republish?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.republish?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#duplicate?' do
    it 'duplicate?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.duplicate?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#matedit?' do
    it 'matedit?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.matedit?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_private_before_matedit?' do
    it 'set_private_before_matedit?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.set_private_before_matedit?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#copy?' do
    it 'copy?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.copy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_basic?' do
    it 'update_basic?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.update_basic?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update?' do
    it 'update?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.update?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#archive?' do
    it 'archive?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.archive?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#unarchive?' do
    it 'unarchive?' do
      external_activity_policy = described_class.new(nil, nil)
      result = external_activity_policy.unarchive?

      expect(result).to be_nil
    end
  end


end
