require 'spec_helper'

describe ExternalActivityPolicy do
  subject                 { ExternalActivityPolicy.new(active_user, activity)   }
  let(:active_user)       { nil                                                 }
  let(:activity)          { FactoryGirl.create(:external_activity)              }

  context "for anonymous" do
    it { is_expected.to permit(:preview_index)           }
    it { is_expected.not_to permit(:publish)             }
    it { is_expected.not_to permit(:duplicate)           }
    it { is_expected.not_to permit(:matedit)             }
    it { is_expected.not_to permit(:duplicate)           }
    it { is_expected.not_to permit(:copy)                }
    it { is_expected.not_to permit(:edit_basic)          }
    it { is_expected.not_to permit(:update)              }
    it { is_expected.not_to permit(:archive)             }
    it { is_expected.not_to permit(:unarchive)           }
    it { is_expected.not_to permit(:edit_credits)        }
  end


  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }

    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.not_to permit(:publish)              }
    it { is_expected.not_to permit(:duplicate)            }
    it { is_expected.not_to permit(:matedit)              }
    it { is_expected.not_to permit(:duplicate)            }
    it { is_expected.not_to permit(:edit_basic)           }
    it { is_expected.not_to permit(:update)               }
    it { is_expected.not_to permit(:archive)              }
    it { is_expected.not_to permit(:unarchive)            }
    it { is_expected.not_to permit(:edit_credits)        }
  end

  context "for the owner" do
    let(:email)      { 'foo@robots.gov' }
    let(:active_user){ FactoryGirl.create(:user, email: email) }
    let(:activity)   { FactoryGirl.create(:external_activity, user: active_user, author_email: email)  }
    before(:each) do
      active_user.add_role('author')
    end

    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.to permit(:publish)                  }
    it { is_expected.to permit(:matedit)                  }
    it { is_expected.to permit(:edit_basic)               }
    it { is_expected.to permit(:archive)                  }
    it { is_expected.to permit(:unarchive)                }

    # not sure why. Just documenting:
    it { is_expected.not_to permit(:duplicate)            }

    it { is_expected.not_to permit(:edit_credits)         }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }

    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.to permit(:publish)                  }
    it { is_expected.to permit(:matedit)                  }
    it { is_expected.to permit(:edit_basic)               }
    it { is_expected.to permit(:archive)                  }
    it { is_expected.to permit(:unarchive)                }
    it { is_expected.to permit(:duplicate)                }
    it { is_expected.to permit(:edit_credits)             }
  end


  context "for a material admin" do
    let(:project_a)   { FactoryGirl.create(:project)                                 }
    let(:active_user) { FactoryGirl.create(:user, admin_for_projects: [project_a])   }
    let(:activity)    { FactoryGirl.create(:external_activity, projects: [project_a])}
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
    end
    it { is_expected.to permit(:preview_index)            }
    it { is_expected.to permit(:copy)                     }
    it { is_expected.to permit(:publish)                  }
    it { is_expected.to permit(:matedit)                  }
    it { is_expected.to permit(:edit_basic)               }
    it { is_expected.to permit(:archive)                  }
    it { is_expected.to permit(:unarchive)                }
    it { is_expected.to permit(:duplicate)                }
    it { is_expected.to permit(:edit_credits)             }
  end

  context "for an admin of a project that is not one of the material's projects" do
    let(:project_a)   { FactoryGirl.create(:project)                                 }
    let(:active_user) { FactoryGirl.create(:user, admin_for_projects: [project_a])   }
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

end
