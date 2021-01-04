class Portal::Nces06SchoolsController < ApplicationController

  # PUNDIT_CHECK_FILTERS
  before_filter :admin_or_manager, :except => [ :description, :index ]
  include RestrictedPortalController

  protected

  def admin_only
    unless current_visitor.has_role?('admin')
      raise Pundit::NotAuthorizedError
    end
  end

  def admin_or_manager
    if current_visitor.has_role?('admin')
      @admin_role = true
    elsif current_visitor.has_role?('manager')
      @manager_role = true
    else
      raise Pundit::NotAuthorizedError
    end
  end

  public

  # GET /portal_nces06_schools
  # GET /portal_nces06_schools.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Nces06School
    select = "id, SCHNAM"
    if params[:state_or_province]
      @nces06_schools = Portal::Nces06School.where("MSTATE = ?", params[:state_or_province]).select(select).order('SCHNAM')
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @nces06_schools = policy_scope(Portal::Nces06School)
    elsif params[:nces_district_id]
      @nces06_schools = Portal::Nces06School.where("nces_district_id = ?", params[:nces_district_id]).select(select).order('SCHNAM')
    else
      @nces06_schools = Portal::Nces06School.select(select).order('SCHNAM')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nces06_schools }
      format.json { render :json => @nces06_schools }
    end
  end

  # GET /portal_nces06_schools/1
  # GET /portal_nces06_schools/1.xml
  def show
    @nces06_school = Portal::Nces06School.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_school

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nces06_school }
    end
  end

  # GET /portal_nces06_schools/new
  # GET /portal_nces06_schools/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Nces06School
    @nces06_school = Portal::Nces06School.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nces06_school }
    end
  end

  # GET /portal_nces06_schools/1/edit
  def edit
    @nces06_school = Portal::Nces06School.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_school
  end

  # POST /portal_nces06_schools
  # POST /portal_nces06_schools.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::Nces06School
    @nces06_school = Portal::Nces06School.new(portal_nces06_school_strong_params(params[:nces06_school]))

    respond_to do |format|
      if @nces06_school.save
        flash['notice'] = 'Portal::Nces06School was successfully created.'
        format.html { redirect_to(@nces06_school) }
        format.xml  { render :xml => @nces06_school, :status => :created, :location => @nces06_school }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nces06_school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_nces06_schools/1
  # PUT /portal_nces06_schools/1.xml
  def update
    @nces06_school = Portal::Nces06School.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_school

    respond_to do |format|
      if @nces06_school.update_attributes(portal_nces06_school_strong_params(params[:nces06_school]))
        flash['notice'] = 'Portal::Nces06School was successfully updated.'
        format.html { redirect_to(@nces06_school) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nces06_school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_nces06_schools/1
  # DELETE /portal_nces06_schools/1.xml
  def destroy
    @nces06_school = Portal::Nces06School.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    # authorize @nces06_school
    @nces06_school.destroy

    respond_to do |format|
      format.html { redirect_to(portal_nces06_schools_url) }
      format.xml  { head :ok }
    end
  end

  def description
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::Nces06School
    # authorize @nces06_school
    # authorize Portal::Nces06School, :new_or_create?
    # authorize @nces06_school, :update_edit_or_destroy?
    @nces06_school = Portal::Nces06School.find(params[:id])
    respond_to do |format|
      format.json { render :json => @nces06_school.summary.to_json, :layout => false }
    end
  end

  def portal_nces06_school_strong_params(params)
    params && params.permit(:AM, :AM01F, :AM01M, :AM01U, :AM02F, :AM02M, :AM02U, :AM03F, :AM03M, :AM03U, :AM04F, :AM04M, :AM04U,
                            :AM05F, :AM05M, :AM05U, :AM06F, :AM06M, :AM06U, :AM07F, :AM07M, :AM07U, :AM08F, :AM08M, :AM08U, :AM09F,
                            :AM09M, :AM09U, :AM10F, :AM10M, :AM10U, :AM11F, :AM11M, :AM11U, :AM12F, :AM12M, :AM12U, :AMALF, :AMALM,
                            :AMALU, :AMKGF, :AMKGM, :AMKGU, :AMPKF, :AMPKM, :AMPKU, :AMUGF, :AMUGM, :AMUGU, :AS01F, :AS01M, :AS01U,
                            :AS02F, :AS02M, :AS02U, :AS03F, :AS03M, :AS03U, :AS04F, :AS04M, :AS04U, :AS05F, :AS05M, :AS05U, :AS06F,
                            :AS06M, :AS06U, :AS07F, :AS07M, :AS07U, :AS08F, :AS08M, :AS08U, :AS09F, :AS09M, :AS09U, :AS10F, :AS10M,
                            :AS10U, :AS11F, :AS11M, :AS11U, :AS12F, :AS12M, :AS12U, :ASALF, :ASALM, :ASALU, :ASIAN, :ASKGF, :ASKGM,
                            :ASKGU, :ASPKF, :ASPKM, :ASPKU, :ASUGF, :ASUGM, :ASUGU, :BL01F, :BL01M, :BL01U, :BL02F, :BL02M, :BL02U,
                            :BL03F, :BL03M, :BL03U, :BL04F, :BL04M, :BL04U, :BL05F, :BL05M, :BL05U, :BL06F, :BL06M, :BL06U, :BL07F,
                            :BL07M, :BL07U, :BL08F, :BL08M, :BL08U, :BL09F, :BL09M, :BL09U, :BL10F, :BL10M, :BL10U, :BL11F, :BL11M,
                            :BL11U, :BL12F, :BL12M, :BL12U, :BLACK, :BLALF, :BLALM, :BLALU, :BLKGF, :BLKGM, :BLKGU, :BLPKF, :BLPKM,
                            :BLPKU, :BLUGF, :BLUGM, :BLUGU, :CDCODE, :CHARTR, :CONAME, :CONUM, :FIPST, :FRELCH, :FTE, :G01, :G02,
                            :G03, :G04, :G05, :G06, :G07, :G08, :G09, :G10, :G11, :G12, :GSHI, :GSLO, :HI01F, :HI01M, :HI01U, :HI02F,
                            :HI02M, :HI02U, :HI03F, :HI03M, :HI03U, :HI04F, :HI04M, :HI04U, :HI05F, :HI05M, :HI05U, :HI06F, :HI06M,
                            :HI06U, :HI07F, :HI07M, :HI07U, :HI08F, :HI08M, :HI08U, :HI09F, :HI09M, :HI09U, :HI10F, :HI10M, :HI10U,
                            :HI11F, :HI11M, :HI11U, :HI12F, :HI12M, :HI12U, :HIALF, :HIALM, :HIALU, :HIKGF, :HIKGM, :HIKGU, :HIPKF,
                            :HIPKM, :HIPKU, :HISP, :HIUGF, :HIUGM, :HIUGU, :IAM, :IAM01F, :IAM01M, :IAM01U, :IAM02F, :IAM02M, :IAM02U,
                            :IAM03F, :IAM03M, :IAM03U, :IAM04F, :IAM04M, :IAM04U, :IAM05F, :IAM05M, :IAM05U, :IAM06F, :IAM06M, :IAM06U,
                            :IAM07F, :IAM07M, :IAM07U, :IAM08F, :IAM08M, :IAM08U, :IAM09F, :IAM09M, :IAM09U, :IAM10F, :IAM10M, :IAM10U,
                            :IAM11F, :IAM11M, :IAM11U, :IAM12F, :IAM12M, :IAM12U, :IAMALF, :IAMALM, :IAMALU, :IAMKGF, :IAMKGM, :IAMKGU,
                            :IAMPKF, :IAMPKM, :IAMPKU, :IAMUGF, :IAMUGM, :IAMUGU, :IAS01F, :IAS01M, :IAS01U, :IAS02F, :IAS02M, :IAS02U,
                            :IAS03F, :IAS03M, :IAS03U, :IAS04F, :IAS04M, :IAS04U, :IAS05F, :IAS05M, :IAS05U, :IAS06F, :IAS06M, :IAS06U,
                            :IAS07F, :IAS07M, :IAS07U, :IAS08F, :IAS08M, :IAS08U, :IAS09F, :IAS09M, :IAS09U, :IAS10F, :IAS10M, :IAS10U,
                            :IAS11F, :IAS11M, :IAS11U, :IAS12F, :IAS12M, :IAS12U, :IASALF, :IASALM, :IASALU, :IASIAN, :IASKGF, :IASKGM,
                            :IASKGU, :IASPKF, :IASPKM, :IASPKU, :IASUGF, :IASUGM, :IASUGU, :IBL01F, :IBL01M, :IBL01U, :IBL02F, :IBL02M,
                            :IBL02U, :IBL03F, :IBL03M, :IBL03U, :IBL04F, :IBL04M, :IBL04U, :IBL05F, :IBL05M, :IBL05U, :IBL06F, :IBL06M,
                            :IBL06U, :IBL07F, :IBL07M, :IBL07U, :IBL08F, :IBL08M, :IBL08U, :IBL09F, :IBL09M, :IBL09U, :IBL10F, :IBL10M,
                            :IBL10U, :IBL11F, :IBL11M, :IBL11U, :IBL12F, :IBL12M, :IBL12U, :IBLACK, :IBLALF, :IBLALM, :IBLALU, :IBLKGF,
                            :IBLKGM, :IBLKGU, :IBLPKF, :IBLPKM, :IBLPKU, :IBLUGF, :IBLUGM, :IBLUGU, :ICHART, :IETH, :IFRELC, :IFTE,
                            :IG01, :IG02, :IG03, :IG04, :IG05, :IG06, :IG07, :IG08, :IG09, :IG10, :IG11, :IG12, :IGSHI, :IGSLO, :IHI01F,
                            :IHI01M, :IHI01U, :IHI02F, :IHI02M, :IHI02U, :IHI03F, :IHI03M, :IHI03U, :IHI04F, :IHI04M, :IHI04U, :IHI05F,
                            :IHI05M, :IHI05U, :IHI06F, :IHI06M, :IHI06U, :IHI07F, :IHI07M, :IHI07U, :IHI08F, :IHI08M, :IHI08U, :IHI09F,
                            :IHI09M, :IHI09U, :IHI10F, :IHI10M, :IHI10U, :IHI11F, :IHI11M, :IHI11U, :IHI12F, :IHI12M, :IHI12U, :IHIALF,
                            :IHIALM, :IHIALU, :IHIKGF, :IHIKGM, :IHIKGU, :IHIPKF, :IHIPKM, :IHIPKU, :IHISP, :IHIUGF, :IHIUGM, :IHIUGU,
                            :IKG, :IMAGNE, :IMEMB, :IMIGRN, :IPK, :IPUTCH, :IREDLC, :ISHARE, :ISTITL, :ITITLI, :ITOTFR, :ITOTGR, :IUG,
                            :IWH01F, :IWH01M, :IWH01U, :IWH02F, :IWH02M, :IWH02U, :IWH03F, :IWH03M, :IWH03U, :IWH04F, :IWH04M, :IWH04U,
                            :IWH05F, :IWH05M, :IWH05U, :IWH06F, :IWH06M, :IWH06U, :IWH07F, :IWH07M, :IWH07U, :IWH08F, :IWH08M, :IWH08U,
                            :IWH09F, :IWH09M, :IWH09U, :IWH10F, :IWH10M, :IWH10U, :IWH11F, :IWH11M, :IWH11U, :IWH12F, :IWH12M, :IWH12U,
                            :IWHALF, :IWHALM, :IWHALU, :IWHITE, :IWHKGF, :IWHKGM, :IWHKGU, :IWHPKF, :IWHPKM, :IWHPKU, :IWHUGF, :IWHUGM,
                            :IWHUGU, :KG, :KIND, :LATCOD, :LCITY, :LEAID, :LEANM, :LEVEL, :LONCOD, :LSTATE, :LSTREE, :LZIP, :LZIP4,
                            :MAGNET, :MCITY, :MEMBER, :MIGRNT, :MSTATE, :MSTREE, :MZIP, :MZIP4, :NCESSCH, :PHONE, :PK, :PUPTCH, :REDLCH,
                            :SCHNAM, :SCHNO, :SEASCH, :SHARED, :STATUS, :STID, :STITLI, :TITLEI, :TOTETH, :TOTFRL, :TOTGRD, :UG, :ULOCAL,
                            :WH01F, :WH01M, :WH01U, :WH02F, :WH02M, :WH02U, :WH03F, :WH03M, :WH03U, :WH04F, :WH04M, :WH04U, :WH05F, :WH05M,
                            :WH05U, :WH06F, :WH06M, :WH06U, :WH07F, :WH07M, :WH07U, :WH08F, :WH08M, :WH08U, :WH09F, :WH09M, :WH09U, :WH10F,
                            :WH10M, :WH10U, :WH11F, :WH11M, :WH11U, :WH12F, :WH12M, :WH12U, :WHALF, :WHALM, :WHALU, :WHITE, :WHKGF, :WHKGM,
                            :WHKGU, :WHPKF, :WHPKM, :WHPKU, :WHUGF, :WHUGM, :WHUGU, :nces_district_id)
  end
end
