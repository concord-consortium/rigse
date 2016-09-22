require 'spec_helper'

describe ExternalActivityPolicy do
  subject                 { ExternalActivityPolicy.new(active_user, activity)   }
  let(:active_user)       { nil                                                 }
  let(:activity)          { FactoryGirl.create(:external_activity)              }

  context "for anonymous" do
    it { should permit(:preview_index)           }
    it { should_not permit(:publish)             }
    it { should_not permit(:duplicate)           }
    it { should_not permit(:matedit)             }
    it { should_not permit(:duplicate)           }
    it { should_not permit(:copy)                }
    it { should_not permit(:edit_basic)          }
    it { should_not permit(:update)              }
    it { should_not permit(:archive)             }
    it { should_not permit(:unarchive)           }
    it { should_not permit(:edit_credits)        }
  end


  context "for a normal user" do
    let(:active_user) { FactoryGirl.create(:user) }

    it { should permit(:preview_index)            }
    it { should permit(:copy)                     }
    it { should_not permit(:publish)              }
    it { should_not permit(:duplicate)            }
    it { should_not permit(:matedit)              }
    it { should_not permit(:duplicate)            }
    it { should_not permit(:edit_basic)           }
    it { should_not permit(:update)               }
    it { should_not permit(:archive)              }
    it { should_not permit(:unarchive)            }
    it { should_not permit(:edit_credits)        }
  end

  context "for the owner" do
    let(:email)      { 'foo@robots.gov' }
    let(:active_user){ FactoryGirl.create(:user, email: email) }
    let(:activity)   { FactoryGirl.create(:external_activity, user: active_user, author_email: email)  }
    before(:each) do
      active_user.add_role('author')
    end

    it { should permit(:preview_index)            }
    it { should permit(:copy)                     }
    it { should permit(:publish)                  }
    it { should permit(:matedit)                  }
    it { should permit(:edit_basic)               }
    it { should permit(:archive)                  }
    it { should permit(:unarchive)                }

    # not sure why. Just documenting:
    it { should_not permit(:duplicate)            }

    it { should_not permit(:edit_credits)         }
  end

  context "for an admin" do
    let(:active_user) { Factory.next(:admin_user)   }

    it { should permit(:preview_index)            }
    it { should permit(:copy)                     }
    it { should permit(:publish)                  }
    it { should permit(:matedit)                  }
    it { should permit(:edit_basic)               }
    it { should permit(:archive)                  }
    it { should permit(:unarchive)                }
    it { should permit(:duplicate)                }
    it { should permit(:edit_credits)             }
  end


  context "for a project admin" do
    let(:project_a)   { FactoryGirl.create(:project)                                 }
    let(:active_user) { FactoryGirl.create(:user, admin_for_projects: [project_a])   }
    let(:activity)    { FactoryGirl.create(:external_activity, projects: [project_a])}
    before(:each) do
      active_user.add_role_for_project('admin', project_a)
    end
    it { should permit(:preview_index)            }
    it { should permit(:copy)                     }
    it { should permit(:publish)                  }
    it { should permit(:matedit)                  }
    it { should permit(:edit_basic)               }
    it { should permit(:archive)                  }
    it { should permit(:unarchive)                }
    it { should permit(:duplicate)                }
    it { should permit(:edit_credits)             }
  end

end