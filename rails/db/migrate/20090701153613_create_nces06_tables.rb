class CreateNces06Tables < ActiveRecord::Migration

  def self.up
    create_table :portal_nces06_districts do |t|
      t.string  :LEAID,     :limit => 7       # NCES Local Education Agency ID.  The first two positions of this field are also the Federal Information Profesing Standards (FIPS) state code.
      t.string  :FIPST,     :limit => 2       # Federal Information Processing Standards (FIPS) state code.
      t.string  :STID,      :limit => 14      # Stateís own ID for the education agency.
      t.string  :NAME,      :limit => 60      # Name of the education agency.
      t.string  :PHONE,     :limit => 10      # Telephone number of education agency. NOTE: Position #0082ñ0084 is the area code, and position #0085ñ0091 is the exchange and number.
      t.string  :MSTREE,    :limit => 30      # Mailing address of the agencyómay be a street address, a P.O. Box number, or, if there is no address beyond CITY, STATE, and ZIP, the character ìN.î
      t.string  :MCITY,     :limit => 30      # Name of the agency mailing address city.
      t.string  :MSTATE,    :limit => 2       # Two-letter U.S. Postal Service abbreviation for the state where the mailing address is located.
      t.string  :MZIP,      :limit => 5       # Five-digit U.S. Postal Service ZIP code for the mailing address.
      t.string  :MZIP4,     :limit => 4       # Four-digit ZIP+4, if assigned; if none, field is blank.
      t.string  :LSTREE,    :limit => 30      # Location address of agency.
      t.string  :LCITY,     :limit => 30      # Location city of agency.
      t.string  :LSTATE,    :limit => 2       # Location state (two-letter postal abbreviation).
      t.string  :LZIP,      :limit => 5       # Location 5-digit ZIP Code.
      t.string  :LZIP4,     :limit => 4       # Location +4 ZIP Code.
      t.string  :KIND,      :limit => 1       # Agency type code:
      t.string  :UNION,     :limit => 3       # Supervisory union number.  For supervisory union administrative centers and component agencies, this is a number assigned by the state to the union. Additionally, if the agency is a county superintendent, this is the FIPS county number. If no number was reported, the field will contain ì000.î
      t.string  :CONUM,     :limit => 5       # FIPS county number (two digit FIPS state numeric code + three digits FIPS county code) based on the location of the administrative office.FIPS county number.
      t.string  :CONAME,    :limit => 30      # County name based on the location of the administrative office.
      t.string  :CSA,       :limit => 3       # Combined Statistical Area (CSA). The CSA assignment is based on the CSA assignments of schools associated with the agency, weighted by the number of students in each school. A CSA may comprise two or more metropolitan statistical areas, a metropolitan statistical area and a micropolitan
      t.string  :CBSA,      :limit => 5       # Core Based Statistical Area (CBSA). A value in this field indicates that the agency's address is associated with a recognized population nucleus and adjacent communities that have a high degree of integration with that nucleus, and designated by the U.S. Government as a metropolitan or micropolitan statistical area. The integration of adjacent communities is determined by the CBSAs of schools associated with the agency, weighted by the number of students in each school.  If the agency is not in any type of metropolitan/micropolitan statistical area the field contains an "N" (not applicable).
      t.string  :METMIC,    :limit => 1       # Indicates whether the CBSA is a metropolitan or micropolitan area.
      t.string  :MSC,       :limit => 1       # NCES classification of the agencyís service area relative to a CBSA.
      t.string  :ULOCAL,    :limit => 2       # NCES urban-centric locale code.
      t.string  :CDCODE,    :limit => 4       # Congressional district code based on location of administrative office. FIPS numeric code for the congressional districts that are legislatively defined subdivision of the state for the purpose of electing representatives to the House of Representative of the United States Congress. The first two digits are the FIPS state numeric code, which makes the congressional district code unique across states (see Appendix C Glossary for detail). If an agency serves more than one congressional district, the code represents the primary one.
      t.float   :LATCOD                       # Latitude. Based on the location of the administrative office, the value of LATCOD ranges from 17 to 71. It contains an explicit decimal point. The digits to the left of the decimal represent the number of degrees from the equator; the digits to the right of the decimal represent the fraction of the next degree carried out to six decimal places.
      t.float   :LONCOD                       # Longitude. Based on the location of the administrative office, the value of LONCOD ranges from -65 to -177. The minus sign (-) indicates west of the prime meridian. It contains an explicit decimal point. The digits to the left of the decimal point represent the number of degrees from the prime meridian; the digits to the right of the decimal point represent the fraction of the next degree carried out to six decimal places.
      t.string  :BOUND,     :limit => 1       # The boundary change indicator is a classification of changes in an education agencyís boundaries since the last report to NCES. The options are as follows:
      t.string  :GSLO,      :limit => 2       # Agency low grade offered. If grade span data were not reported, this field was calculated from the low grade spans of the associated schools in the CCD school universe file.
      t.string  :GSHI,      :limit => 2       # Agency high grade offered. If grade span data were not reported, this field was calculated from the high grade spans of the associated schools in the CCD school universe file. When combined, GSLO and GSHI are the grade span of the school.
      t.string  :AGCHRT,    :limit => 1       # Agency charter. Code indicating charter schools served:
      t.integer :SCH                          # Aggregate number of schools associated with this agency in the CCD school universe file.
      t.float   :TEACH                        # Aggregate full-time-equivalent (FTE) classroom teachers reported for schools associated with this agency in the CCD school universe file, reported to the nearest tenth; field includes one explicit decimal point.  This is not necessarily the total number of teachers employed by the agency.
      t.integer :UG                           # Total number of students in classes or programs without standard grade   designations.
      t.integer :PK12                         # Total number of students in classes from prekindergarten through 12th grade that are part of the public school program.
      t.integer :MEMBER                       # Calculated total student membership of the local education agency: the sum of the fields UG and PK12.
      t.integer :MIGRNT                       # The number of migrant students, as defined under 34 CFR 200.40, enrolled in summer programs during the summer immediately prior to the 2006ñ07 school year.
      t.integer :SPECED                       # Count of all students having a written Individualized Education Program (IEP) under the Individuals With Disabilities Education Act (IDEA), Part B.
      t.integer :ELL                          # The number of English language learner (ELL) students served in appropriate programs.
      t.float   :PKTCH                        # Prekindergarten teachers. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :KGTCH                        # Kindergarten teachers. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :ELMTCH                       # Elementary teachers. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :SECTCH                       # Secondary teachers. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :UGTCH                        # Teachers of classes or programs to which students are assigned without standard grade designation. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :TOTTCH                       # Total teachers. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :AIDES                        # Instructional aides. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :CORSUP                       # Instructional coordinators & supervisors. Full-time equivalency reported to the nearest tenth; includes one explicit decimal.
      t.float   :ELMGUI                       # Elementary guidance counselors. Full-time equivalency reported to the nearest tenth; includes one explicit decimal.
      t.float   :SECGUI                       # Secondary guidance counselors. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :TOTGUI                       # Total guidance counselors. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :LIBSPE                       # Librarians/media specialists. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :LIBSUP                       # Library/media support staff. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :LEAADM                       # LEA administrators. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :LEASUP                       # LEA administrative support staff. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :SCHADM                       # School administrators. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :SCHSUP                       # School administrative support staff. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :STUSUP                       # Student support services staff. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.float   :OTHSUP                       # All other support services staff. Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.string  :IGSLO,     :limit => 1       # If this field contains anything other than ìR,î the GSLO value originally submitted was adjusted.
      t.string  :IGSHI,     :limit => 1       # If this field contains anything other than ìR,î the GSHI value originally submitted was adjusted.
      t.string  :ISCH,      :limit => 1       # If this field contains anything other than ìT,î the aggregate number of schools associated with this agency in the school universe file was adjusted.
      t.string  :ITEACH,    :limit => 1       # If this field contains anything other than ìT,î the aggregate FTE classroom teacher count reported for schools associated with this agency in the school universe file was adjusted.
      t.string  :IUG,       :limit => 1       # If this field contains anything other than ìR,î the ungraded student count originally submitted was adjusted.
      t.string  :IPK12,     :limit => 1       # If this field contains anything other than ìR,î the PK through 12 student count originally submitted was adjusted.
      t.string  :IMEMB,     :limit => 1       # If this field contains anything other than ìT,î the total student count (ungraded plus PK through 12) was adjusted.
      t.string  :IMIGRN,    :limit => 1       # If this field contains anything other than ìR,î the migrant student count originally submitted was adjusted.
      t.string  :ISPEC,     :limit => 1       # If this field contains anything other than ìR,î the special education/IEP count originally submitted was adjusted.
      t.string  :IELL,      :limit => 1       # If this field contains anything other than ìR,î the English language learner student count originally submitted was adjusted.
      t.string  :IPKTCH,    :limit => 1       # If this field contains anything other than ìR,î the prekindergarten teacher count originally submitted was adjusted.
      t.string  :IKGTCH,    :limit => 1       # If this field contains anything other than ìR,î the kindergarten teacher count originally submitted was adjusted.
      t.string  :IELTCH,    :limit => 1       # If this field contains anything other than ìR,î the elementary teacher count originally submitted was adjusted.
      t.string  :ISETCH,    :limit => 1       # If this field contains anything other than ìR,î the secondary teacher count originally submitted was adjusted.
      t.string  :IUGTCH,    :limit => 1       # If this field contains anything other than ìR,î the teachers of ungraded classes count originally submitted was adjusted.
      t.string  :ITOTCH,    :limit => 1       # If this field contains anything other than ìR,î the total FTE teacher count originally submitted was adjusted.
      t.string  :IAIDES,    :limit => 1       # If this field contains anything other than ìR,î the instructional aides count originally submitted was adjusted.
      t.string  :ICOSUP,    :limit => 1       # If this field contains anything other than ìR,î the instructional coordinators and supervisors count originally submitted was adjusted.
      t.string  :IELGUI,    :limit => 1       # If this field contains anything other than ìR,î the elementary guidance counselors count originally submitted was adjusted.
      t.string  :ISEGUI,    :limit => 1       # If this field contains anything other than ìR,î the secondary guidance counselors count originally submitted was adjusted.
      t.string  :ITOGUI,    :limit => 1       # If this field contains anything other than ìR,î the total guidance counselors count originally submitted was adjusted.
      t.string  :ILISPE,    :limit => 1       # If this field contains anything other than ìR,î the librarians/media specialists count originally submitted was adjusted.
      t.string  :ILISUP,    :limit => 1       # If this field contains anything other than ìR,î the library/media support staff count originally submitted was adjusted.
      t.string  :ILEADM,    :limit => 1       # If this field contains anything other than ìR,î the LEA administrators count originally submitted was adjusted.
      t.string  :ILESUP,    :limit => 1       # If this field contains anything other than ìR,î the LEA administrative support staff count originally submitted was adjusted.
      t.string  :ISCADM,    :limit => 1       # If this field contains anything other than ìR,î the school administrative support staff count originally submitted was adjusted.
      t.string  :ISCSUP,    :limit => 1       # If this field contains anything other than ìR,î the school administrative support staff count originally submitted was adjusted.
      t.string  :ISTSUP,    :limit => 1       # If this field contains anything other than ìR,î the student support services staff count originally submitted was adjusted.
      t.string  :IOTSUP,    :limit => 1       # If this field contains anything other than ìR,î the all other support services staff count originally submitted was adjusted.
    end


    create_table :portal_nces06_schools do |t|
      t.integer :nces_district_id
      t.string  :NCESSCH,   :limit => 12      # Unique NCES public school ID (7-digit NCES agency ID (LEAID) + 5-digit NCES school ID (SCHNO).
      t.string  :FIPST,     :limit => 2       # Federal Information Processing Standards (FIPS) state numeric code.
      t.string  :LEAID,     :limit => 7       # NCES local education agency (LEA) ID. NOTE: The state to which the LEA belongs is identified by the first two digits (FIPS code) of the LEAID.
      t.string  :SCHNO,     :limit => 5       # NCES school ID. NOTE:  SCHNO is a unique number within an LEA.By combining LEAID with SCHNO, each school can be uniquely identified within the total file (see NCESSCH above).
      t.string  :STID,      :limit => 14      # State's own ID for the education agency.
      t.string  :SEASCH,    :limit => 20      # State's own ID for the school.
      t.string  :LEANM,     :limit => 60      # Name of the education agency that operates this school.
      t.string  :SCHNAM,    :limit => 50      # Name of the school.
      t.string  :PHONE,     :limit => 10      # Telephone number of school.NOTE: Position # 0157-0159 is the area code, and position #0160-0166 is the exchange and number.
      t.string  :MSTREE,    :limit => 30      # The mailing address of the schooló may be a street address, a P.O. Box number, or, if verified that there is no address beyond CITY, STATE, and ZIP, the character ìN.î
      t.string  :MCITY,     :limit => 30      # School mailing address city.
      t.string  :MSTATE,    :limit => 2       # Two-letter U.S. Postal Service abbreviation of the state where the mailing address is located (see FIPS state codes and abbreviations used in CCD dataset).
      t.string  :MZIP,      :limit => 5       # Five-digit U.S. Postal Service ZIP code for the mailing address.
      t.string  :MZIP4,     :limit => 4       # Four-digit (ZIP+4) code for the mailing address. If the mailing address has been assigned the additional four-digit +4 ZIP, this field contains that number; otherwise, this field is blank.
      t.string  :LSTREE,    :limit => 30      # School location street address.
      t.string  :LCITY,     :limit => 30      # School location city.
      t.string  :LSTATE,    :limit => 2       # Two-letter U.S. Postal Service abbreviation of the state where the school address is located (see FIPS state codes and abbreviations used in CCD dataset).
      t.string  :LZIP,      :limit => 5       # Five-digit U.S. Postal Service ZIP code for the location address.
      t.string  :LZIP4,     :limit => 4       # Four-digit (ZIP+4) code for the location address. If the mailing address has been assigned the additional four-digit +4 ZIP, this field contains that number; otherwise, this field is blank.
      t.string  :KIND,      :limit => 1       # NCES code for type of school:
      t.string  :STATUS,    :limit => 1       # NCES code for the school status:
      t.string  :ULOCAL,    :limit => 2       # NCES urban-centric locale code. NOTE: Starting in 2006ñ07, CCD data files contain a new locale code system that is based on the urbanicity of the school location.  In prior years, the locale code was assigned based on a schoolís metro status.  See appendix C, Glossary, for more detail.
      t.float   :LATCOD                       # Latitude: Based on the location of the school, the value of LATCOD ranges from 17 to 71. It contains an explicit decimal point. The digits to the left of the decimal represent the number of degrees from the equator; the digits to the right of the decimal represent the fraction of the next degree carried out to six decimal places.
      t.float   :LONCOD                       # Longitude: Based on the location of the school, the value of LONCOD ranges from -65 to -177. The minus sign (-) indicates west of the prime meridian. It contains an explicit decimal point. The digits to the left of the decimal point represent the number of degrees from the prime meridian; the digits to the right of the decimal point represent the fraction of the next degree carried out to six decimal places.
      t.string  :CDCODE,    :limit => 4       # Congressional district code based on the location of the school. FIPS numeric code for the congressional districts that are legislatively defined subdivision of the state for the purpose of electing representatives to the House of Representative of the United States Congress. The first two digits are the FIPS state numeric code, which makes the congressional district code unique across states (see appendix C, Glossary for detail). If an agency serves more than one congressional district, the code represents the primary one.
      t.string  :CONUM,     :limit => 5       # FIPS county number (two digit FIPS state numeric code + three digits FIPS county code) based on the location of the school.
      t.string  :CONAME,    :limit => 30      # County name based on the location of the school.
      t.float   :FTE                          # Total full-time-equivalent classroom teachers.  Full-time equivalency reported to the nearest tenth; field includes one explicit decimal.
      t.string  :GSLO,      :limit => 2       # School low grade offered. The following codes are used:
      t.string  :GSHI,      :limit => 2       # School high grade offered.  The following codes are used:
      t.string  :LEVEL,     :limit => 1       # School level.  The following codes were calculated from the school's corresponding GSLO and GSHI values:
      t.string  :TITLEI,    :limit => 1       # Title I Eligible School.  A Title I school designated under appropriate state and federal regulations as being eligible for participation in programs authorized by Title I of Public Law 103-382.
      t.string  :STITLI,    :limit => 1       # School-wide Title I.  A program in which all the pupils in a school are designated under appropriate state and federal regulations as being eligible for participation in programs authorized by Title I of Public Law 103-382.
      t.string  :MAGNET,    :limit => 1       # Magnet school.  Regardless of the source of funding, a magnet school or program is a special school or program designed to attract students of different racial/ethnic backgrounds for the purpose of reducing, preventing, or eliminating racial isolation and/or to provide an academic or social focus on a particular theme.
      t.string  :CHARTR,    :limit => 1       # Charter school.  A school that provides free elementary and/or secondary education to eligible students under a specific charter granted by the state legislature or other appropriate authority.
      t.string  :SHARED,    :limit => 1       # Shared-time school.  A school offering vocational/technical education or other education services, in which some or all students are enrolled at a separate ìhomeî school and attend the shared-time school on a part-day basis.
      t.integer :FRELCH                       # Count of students eligible to participate in the Free Lunch Program under the National School Lunch Act.
      t.integer :REDLCH                       # Count of students eligible to participate in the Reduced-Price Lunch Program under the National School Lunch Act.
      t.integer :TOTFRL                       # Total of free lunch eligible and reduced-price lunch eligible. The total is only available if both of the details (or the total) were reported.
      t.integer :MIGRNT                       # Migrant students enrolled in previous year.  Cumulative unduplicated (within school) number of migrant students, as defined under 34 CFR 200.40, enrolled anytime during the previous regular school year.
      t.integer :PK                           # Total prekindergarten students.
      t.integer :AMPKM                        # Prekindergarten students - American Indian/Alaska Native - male.
      t.integer :AMPKF                        # Prekindergarten students - American Indian/Alaska Native - female.
      t.integer :AMPKU                        # Prekindergarten students - American Indian/Alaska Native - gender unknown.
      t.integer :ASPKM                        # Prekindergarten students - Asian/Pacific Islander - male.
      t.integer :ASPKF                        # Prekindergarten students - Asian/Pacific Islander - female.
      t.integer :ASPKU                        # Prekindergarten students - Asian/Pacific Islander - gender unknown.
      t.integer :HIPKM                        # Prekindergarten students - Hispanic - male.
      t.integer :HIPKF                        # Prekindergarten students - Hispanic - female.
      t.integer :HIPKU                        # Prekindergarten students - Hispanic - gender unknown.
      t.integer :BLPKM                        # Prekindergarten students - Black, non-Hispanic - male.
      t.integer :BLPKF                        # Prekindergarten students - Black, non-Hispanic - female.
      t.integer :BLPKU                        # Prekindergarten students - Black, non-Hispanic - gender unknown.
      t.integer :WHPKM                        # Prekindergarten students - White, non-Hispanic - male.
      t.integer :WHPKF                        # Prekindergarten students - White, non-Hispanic - female.
      t.integer :WHPKU                        # Prekindergarten students - White, non-Hispanic - gender unknown.
      t.integer :KG                           # Total kindergarten students.
      t.integer :AMKGM                        # Kindergarten students - American Indian/Alaska Native - male.
      t.integer :AMKGF                        # Kindergarten students - American Indian/Alaska Native - female.
      t.integer :AMKGU                        # Kindergarten students - American Indian/Alaska Native - gender unknown.
      t.integer :ASKGM                        # Kindergarten students - Asian/Pacific Islander - male.
      t.integer :ASKGF                        # Kindergarten students - Asian/Pacific Islander - female.
      t.integer :ASKGU                        # Kindergarten students - Asian/Pacific Islander - gender unknown.
      t.integer :HIKGM                        # Kindergarten students - Hispanic - male.
      t.integer :HIKGF                        # Kindergarten students - Hispanic - female.
      t.integer :HIKGU                        # Kindergarten students - Hispanic - gender unknown.
      t.integer :BLKGM                        # Kindergarten students - Black, non-Hispanic - male.
      t.integer :BLKGF                        # Kindergarten students - Black, non-Hispanic - female.
      t.integer :BLKGU                        # Kindergarten students - Black, non-Hispanic - gender unknown.
      t.integer :WHKGM                        # Kindergarten students - White, non-Hispanic - male.
      t.integer :WHKGF                        # Kindergarten students - White, non-Hispanic - female.
      t.integer :WHKGU                        # Kindergarten students - White, non-Hispanic - gender unknown.
      t.integer :G01                          # Total grade 1 students.
      t.integer :AM01M                        # Grade 1 students - American Indian/Alaska Native - male.
      t.integer :AM01F                        # Grade 1 students - American Indian/Alaska Native - female.
      t.integer :AM01U                        # Grade 1 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS01M                        # Grade 1 students - Asian/Pacific Islander - male.
      t.integer :AS01F                        # Grade 1 students - Asian/Pacific Islander - female.
      t.integer :AS01U                        # Grade 1 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI01M                        # Grade 1 students - Hispanic - male.
      t.integer :HI01F                        # Grade 1 students - Hispanic - female.
      t.integer :HI01U                        # Grade 1 students - Hispanic - gender unknown.
      t.integer :BL01M                        # Grade 1 students - Black, non-Hispanic - male.
      t.integer :BL01F                        # Grade 1 students - Black, non-Hispanic - female.
      t.integer :BL01U                        # Grade 1 students - Black, non-Hispanic - gender unknown.
      t.integer :WH01M                        # Grade 1 students - White, non-Hispanic - male.
      t.integer :WH01F                        # Grade 1 students - White, non-Hispanic - female.
      t.integer :WH01U                        # Grade 1 students - White, non-Hispanic - gender unknown.
      t.integer :G02                          # Total grade 2 students.
      t.integer :AM02M                        # Grade 2 students - American Indian/Alaska Native - male.
      t.integer :AM02F                        # Grade 2 students - American Indian/Alaska Native - female.
      t.integer :AM02U                        # Grade 2 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS02M                        # Grade 2 students - Asian/Pacific Islander - male.
      t.integer :AS02F                        # Grade 2 students - Asian/Pacific Islander - female.
      t.integer :AS02U                        # Grade 2 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI02M                        # Grade 2 students - Hispanic - male.
      t.integer :HI02F                        # Grade 2 students - Hispanic - female.
      t.integer :HI02U                        # Grade 2 students - Hispanic - gender unknown.
      t.integer :BL02M                        # Grade 2 students - Black, non-Hispanic - male.
      t.integer :BL02F                        # Grade 2 students - Black, non-Hispanic - female.
      t.integer :BL02U                        # Grade 2 students - Black, non-Hispanic - gender unknown.
      t.integer :WH02M                        # Grade 2 students - White, non-Hispanic - male.
      t.integer :WH02F                        # Grade 2 students - White, non-Hispanic - female.
      t.integer :WH02U                        # Grade 2 students - White, non-Hispanic - gender unknown.
      t.integer :G03                          # Total grade 3 students.
      t.integer :AM03M                        # Grade 3 students - American Indian/Alaska Native - male.
      t.integer :AM03F                        # Grade 3 students - American Indian/Alaska Native - female.
      t.integer :AM03U                        # Grade 3 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS03M                        # Grade 3 students - Asian/Pacific Islander - male.
      t.integer :AS03F                        # Grade 3 students - Asian/Pacific Islander - female.
      t.integer :AS03U                        # Grade 3 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI03M                        # Grade 3 students - Hispanic - male.
      t.integer :HI03F                        # Grade 3 students - Hispanic - female.
      t.integer :HI03U                        # Grade 3 students - Hispanic - gender unknown.
      t.integer :BL03M                        # Grade 3 students - Black, non-Hispanic - male.
      t.integer :BL03F                        # Grade 3 students - Black, non-Hispanic - female.
      t.integer :BL03U                        # Grade 3 students - Black, non-Hispanic - gender unknown.
      t.integer :WH03M                        # Grade 3 students - White, non-Hispanic - male.
      t.integer :WH03F                        # Grade 3 students - White, non-Hispanic - female.
      t.integer :WH03U                        # Grade 3 students - White, non-Hispanic - gender unknown.
      t.integer :G04                          # Total grade 4 students.
      t.integer :AM04M                        # Grade 4 students - American Indian/Alaska Native - male.
      t.integer :AM04F                        # Grade 4 students - American Indian/Alaska Native - female.
      t.integer :AM04U                        # Grade 4 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS04M                        # Grade 4 students - Asian/Pacific Islander - male.
      t.integer :AS04F                        # Grade 4 students - Asian/Pacific Islander - female.
      t.integer :AS04U                        # Grade 4 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI04M                        # Grade 4 students - Hispanic - male.
      t.integer :HI04F                        # Grade 4 students - Hispanic - female.
      t.integer :HI04U                        # Grade 4 students - Hispanic - gender unknown.
      t.integer :BL04M                        # Grade 4 students - Black, non-Hispanic - male.
      t.integer :BL04F                        # Grade 4 students - Black, non-Hispanic - female.
      t.integer :BL04U                        # Grade 4 students - Black, non-Hispanic - gender unknown.
      t.integer :WH04M                        # Grade 4 students - White, non-Hispanic - male.
      t.integer :WH04F                        # Grade 4 students - White, non-Hispanic - female.
      t.integer :WH04U                        # Grade 4 students - White, non-Hispanic - gender unknown.
      t.integer :G05                          # Total grade 5 students.
      t.integer :AM05M                        # Grade 5 students - American Indian/Alaska Native - male.
      t.integer :AM05F                        # Grade 5 students - American Indian/Alaska Native - female.
      t.integer :AM05U                        # Grade 5 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS05M                        # Grade 5 students - Asian/Pacific Islander - male.
      t.integer :AS05F                        # Grade 5 students - Asian/Pacific Islander - female.
      t.integer :AS05U                        # Grade 5 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI05M                        # Grade 5 students - Hispanic - male.
      t.integer :HI05F                        # Grade 5 students - Hispanic - female.
      t.integer :HI05U                        # Grade 5 students - Hispanic - gender unknown.
      t.integer :BL05M                        # Grade 5 students - Black, non-Hispanic - male.
      t.integer :BL05F                        # Grade 5 students - Black, non-Hispanic - female.
      t.integer :BL05U                        # Grade 5 students - Black, non-Hispanic - gender unknown.
      t.integer :WH05M                        # Grade 5 students - White, non-Hispanic - male.
      t.integer :WH05F                        # Grade 5 students - White, non-Hispanic - female.
      t.integer :WH05U                        # Grade 5 students - White, non-Hispanic - gender unknown.
      t.integer :G06                          # Total grade 6 students.
      t.integer :AM06M                        # Grade 6 students - American Indian/Alaska Native - male.
      t.integer :AM06F                        # Grade 6 students - American Indian/Alaska Native - female.
      t.integer :AM06U                        # Grade 6 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS06M                        # Grade 6 students - Asian/Pacific Islander - male.
      t.integer :AS06F                        # Grade 6 students - Asian/Pacific Islander - female.
      t.integer :AS06U                        # Grade 6 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI06M                        # Grade 6 students - Hispanic - male.
      t.integer :HI06F                        # Grade 6 students - Hispanic - female.
      t.integer :HI06U                        # Grade 6 students - Hispanic - gender unknown.
      t.integer :BL06M                        # Grade 6 students - Black, non-Hispanic - male.
      t.integer :BL06F                        # Grade 6 students - Black, non-Hispanic - female.
      t.integer :BL06U                        # Grade 6 students - Black, non-Hispanic - gender unknown.
      t.integer :WH06M                        # Grade 6 students - White, non-Hispanic - male.
      t.integer :WH06F                        # Grade 6 students - White, non-Hispanic - female.
      t.integer :WH06U                        # Grade 6 students - White, non-Hispanic - gender unknown.
      t.integer :G07                          # Total grade 7 students.
      t.integer :AM07M                        # Grade 7 students - American Indian/Alaska Native - male.
      t.integer :AM07F                        # Grade 7 students - American Indian/Alaska Native - female.
      t.integer :AM07U                        # Grade 7 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS07M                        # Grade 7 students - Asian/Pacific Islander - male.
      t.integer :AS07F                        # Grade 7 students - Asian/Pacific Islander - female.
      t.integer :AS07U                        # Grade 7 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI07M                        # Grade 7 students - Hispanic - male.
      t.integer :HI07F                        # Grade 7 students - Hispanic - female.
      t.integer :HI07U                        # Grade 7 students - Hispanic - gender unknown.
      t.integer :BL07M                        # Grade 7 students - Black, non-Hispanic - male.
      t.integer :BL07F                        # Grade 7 students - Black, non-Hispanic - female.
      t.integer :BL07U                        # Grade 7 students - Black, non-Hispanic - gender unknown.
      t.integer :WH07M                        # Grade 7 students - White, non-Hispanic - male.
      t.integer :WH07F                        # Grade 7 students - White, non-Hispanic - female.
      t.integer :WH07U                        # Grade 7 students - White, non-Hispanic - gender unknown.
      t.integer :G08                          # Total grade 8 students.
      t.integer :AM08M                        # Grade 8 students - American Indian/Alaska Native - male.
      t.integer :AM08F                        # Grade 8 students - American Indian/Alaska Native - female.
      t.integer :AM08U                        # Grade 8 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS08M                        # Grade 8 students - Asian/Pacific Islander - male.
      t.integer :AS08F                        # Grade 8 students - Asian/Pacific Islander - female.
      t.integer :AS08U                        # Grade 8 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI08M                        # Grade 8 students - Hispanic - male.
      t.integer :HI08F                        # Grade 8 students - Hispanic - female.
      t.integer :HI08U                        # Grade 8 students - Hispanic - gender unknown.
      t.integer :BL08M                        # Grade 8 students - Black, non-Hispanic - male.
      t.integer :BL08F                        # Grade 8 students - Black, non-Hispanic - female.
      t.integer :BL08U                        # Grade 8 students - Black, non-Hispanic - gender unknown.
      t.integer :WH08M                        # Grade 8 students - White, non-Hispanic - male.
      t.integer :WH08F                        # Grade 8 students - White, non-Hispanic - female.
      t.integer :WH08U                        # Grade 8 students - White, non-Hispanic - gender unknown.
      t.integer :G09                          # Total grade 9 students.
      t.integer :AM09M                        # Grade 9 students - American Indian/Alaska Native - male.
      t.integer :AM09F                        # Grade 9 students - American Indian/Alaska Native - female.
      t.integer :AM09U                        # Grade 9 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS09M                        # Grade 9 students - Asian/Pacific Islander - male.
      t.integer :AS09F                        # Grade 9 students - Asian/Pacific Islander - female.
      t.integer :AS09U                        # Grade 9 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI09M                        # Grade 9 students - Hispanic - male.
      t.integer :HI09F                        # Grade 9 students - Hispanic - female.
      t.integer :HI09U                        # Grade 9 students - Hispanic - gender unknown.
      t.integer :BL09M                        # Grade 9 students - Black, non-Hispanic - male.
      t.integer :BL09F                        # Grade 9 students - Black, non-Hispanic - female.
      t.integer :BL09U                        # Grade 9 students - Black, non-Hispanic - gender unknown.
      t.integer :WH09M                        # Grade 9 students - White, non-Hispanic - male.
      t.integer :WH09F                        # Grade 9 students - White, non-Hispanic - female.
      t.integer :WH09U                        # Grade 9 students - White, non-Hispanic - gender unknown.
      t.integer :G10                          # Total grade 10 students.
      t.integer :AM10M                        # Grade 10 students - American Indian/Alaska Native - male.
      t.integer :AM10F                        # Grade 10 students - American Indian/Alaska Native - female.
      t.integer :AM10U                        # Grade 10 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS10M                        # Grade 10 students - Asian/Pacific Islander - male.
      t.integer :AS10F                        # Grade 10 students - Asian/Pacific Islander - female.
      t.integer :AS10U                        # Grade 10 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI10M                        # Grade 10 students - Hispanic - male.
      t.integer :HI10F                        # Grade 10 students - Hispanic - female.
      t.integer :HI10U                        # Grade 10 students - Hispanic - gender unknown.
      t.integer :BL10M                        # Grade 10 students - Black, non-Hispanic - male.
      t.integer :BL10F                        # Grade 10 students - Black, non-Hispanic - female.
      t.integer :BL10U                        # Grade 10 students - Black, non-Hispanic - gender unknown.
      t.integer :WH10M                        # Grade 10 students - White, non-Hispanic - male.
      t.integer :WH10F                        # Grade 10 students - White, non-Hispanic - female.
      t.integer :WH10U                        # Grade 10 students - White, non-Hispanic - gender unknown.
      t.integer :G11                          # Total grade 11 students.
      t.integer :AM11M                        # Grade 11 students - American Indian/Alaska Native - male.
      t.integer :AM11F                        # Grade 11 students - American Indian/Alaska Native - female.
      t.integer :AM11U                        # Grade 11 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS11M                        # Grade 11 students - Asian/Pacific Islander - male.
      t.integer :AS11F                        # Grade 11 students - Asian/Pacific Islander - female.
      t.integer :AS11U                        # Grade 11 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI11M                        # Grade 11 students - Hispanic - male.
      t.integer :HI11F                        # Grade 11 students - Hispanic - female.
      t.integer :HI11U                        # Grade 11 students - Hispanic - gender unknown.
      t.integer :BL11M                        # Grade 11 students - Black, non-Hispanic - male.
      t.integer :BL11F                        # Grade 11 students - Black, non-Hispanic - female.
      t.integer :BL11U                        # Grade 11 students - Black, non-Hispanic - gender unknown.
      t.integer :WH11M                        # Grade 11 students - White, non-Hispanic - male.
      t.integer :WH11F                        # Grade 11 students - White, non-Hispanic - female.
      t.integer :WH11U                        # Grade 11 students - White, non-Hispanic - gender unknown.
      t.integer :G12                          # Total grade 12 students.
      t.integer :AM12M                        # Grade 12 students - American Indian/Alaska Native - male.
      t.integer :AM12F                        # Grade 12 students - American Indian/Alaska Native - female.
      t.integer :AM12U                        # Grade 12 students - American Indian/Alaska Native - gender unknown.
      t.integer :AS12M                        # Grade 12 students - Asian/Pacific Islander - male.
      t.integer :AS12F                        # Grade 12 students - Asian/Pacific Islander - female.
      t.integer :AS12U                        # Grade 12 students - Asian/Pacific Islander - gender unknown.
      t.integer :HI12M                        # Grade 12 students - Hispanic - male.
      t.integer :HI12F                        # Grade 12 students - Hispanic - female.
      t.integer :HI12U                        # Grade 12 students - Hispanic - gender unknown.
      t.integer :BL12M                        # Grade 12 students - Black, non-Hispanic - male.
      t.integer :BL12F                        # Grade 12 students - Black, non-Hispanic - female.
      t.integer :BL12U                        # Grade 12 students - Black, non-Hispanic - gender unknown.
      t.integer :WH12M                        # Grade 12 students - White, non-Hispanic - male.
      t.integer :WH12F                        # Grade 12 students - White, non-Hispanic - female.
      t.integer :WH12U                        # Grade 12 students - White, non-Hispanic - gender unknown.
      t.integer :UG                           # Total ungraded students.
      t.integer :AMUGM                        # Ungraded students - American Indian/Alaska Native - male.
      t.integer :AMUGF                        # Ungraded students - American Indian/Alaska Native - female.
      t.integer :AMUGU                        # Ungraded students - American Indian/Alaska Native - gender unknown.
      t.integer :ASUGM                        # Ungraded students - Asian/Pacific Islander - male.
      t.integer :ASUGF                        # Ungraded students - Asian/Pacific Islander - female.
      t.integer :ASUGU                        # Ungraded students - Asian/Pacific Islander - gender unknown.
      t.integer :HIUGM                        # Ungraded students - Hispanic - male.
      t.integer :HIUGF                        # Ungraded students - Hispanic - female.
      t.integer :HIUGU                        # Ungraded students - Hispanic - gender unknown.
      t.integer :BLUGM                        # Ungraded students - Black, non-Hispanic - male.
      t.integer :BLUGF                        # Ungraded students - Black, non-Hispanic - female.
      t.integer :BLUGU                        # Ungraded students - Black, non-Hispanic - gender unknown.
      t.integer :WHUGM                        # Ungraded students - White, non-Hispanic - male.
      t.integer :WHUGF                        # Ungraded students - White, non-Hispanic - female.
      t.integer :WHUGU                        # Ungraded students - White, non-Hispanic - gender unknown.
      t.integer :MEMBER                       # Total students, all grades:  The reported total membership of the school.
      t.integer :AM                           # American Indian/Alaska Native students.  If not reported, this field was calculated by summing the AMALM06, AMALF06, and AMALU06 fields.
      t.integer :AMALM                        # Total students, all grades - American Indian/Alaska Native - male.
      t.integer :AMALF                        # Total students, all grades - American Indian/Alaska Native - female.
      t.integer :AMALU                        # Total students, all grades - American Indian/Alaska Native - gender unknown.
      t.integer :ASIAN                        # Asian/Pacific Islander students.  If not reported, this field was calculated by summing the ASALM06, ASALF06, and ASALU06 fields.
      t.integer :ASALM                        # Total students, all grades - Asian/Pacific Islander - male.
      t.integer :ASALF                        # Total students, all grades - Asian/Pacific Islander - female.
      t.integer :ASALU                        # Total students, all grades - Asian/Pacific Islander - gender unknown.
      t.integer :HISP                         # Hispanic students.  If not reported, this field was calculated by summing the HIALM06, HIALF06, and HIALU06 fields.
      t.integer :HIALM                        # Total students, all grades - Hispanic - male.
      t.integer :HIALF                        # Total students, all grades - Hispanic - female.
      t.integer :HIALU                        # Total students, all grades - Hispanic - gender unknown.
      t.integer :BLACK                        # Black, non-Hispanic students.  If not reported, this field was calculated by summing the BLALM06, BLALF06, and BLALU06 fields.
      t.integer :BLALM                        # Total students, all grades - Black, non-Hispanic - male.
      t.integer :BLALF                        # Total students, all grades - Black, non-Hispanic - female.
      t.integer :BLALU                        # Total students, all grades - Black, non-Hispanic - gender unknown.
      t.integer :WHITE                        # White, non-Hispanic students.  If not reported, this field was calculated by summing the WHALM06, WHALF06, and WHALU06 fields.
      t.integer :WHALM                        # Total students, all grades - White, non-Hispanic - male.
      t.integer :WHALF                        # Total students, all grades - White, non-Hispanic - female.
      t.integer :WHALU                        # Total students, all grades - White, non-Hispanic - gender unknown.
      t.integer :TOTETH                       # Calculated school race/ethnicity membership: The sum of the fields AM06, ASIAN06, HISP06, BLACK06, and WHITE06.  Students belonging to an unknown or non-CCD race category are not captured in this field.
      t.float   :PUPTCH                       # Calculated pupil/teacher ratio: Total reported students (MEMBER06) divided by FTE classroom teachers (FTE06).  Reported to the nearest tenth; field includes one explicit decimal.
      t.integer :TOTGRD                       # Calculated school membership: The sum of reported grade totals.  If one of the grade totals is missing, then TOTGRD06 is missing.
      t.string  :IFTE,      :limit => 1       # If the field contains anything other than ìR,î the total classroom teachers count originally submitted was adjusted.
      t.string  :IGSLO,     :limit => 1       # If this field contains anything other than ìR,î the GSLO value originally submitted was adjusted.
      t.string  :IGSHI,     :limit => 1       # If this field contains anything other than ìR,î the GSHI value originally submitted was adjusted.
      t.string  :ITITLI,    :limit => 1       # If the field contains anything other than ìR,î the Title I eligible value originally submitted was adjusted.
      t.string  :ISTITL,    :limit => 1       # If the field contains anything other than ìR,î the school-wide Title I value originally submitted was adjusted.
      t.string  :IMAGNE,    :limit => 1       # If the field contains anything other than ìR,î the magnet school value originally submitted was adjusted.
      t.string  :ICHART,    :limit => 1       # If the field contains anything other than ìR,î the charter school value originally submitted was adjusted.
      t.string  :ISHARE,    :limit => 1       # If the field contains anything other than ìR,î the shared-time school value originally submitted was adjusted.
      t.string  :IFRELC,    :limit => 1       # If the field contains anything other than ìR,î the students eligible for free lunch count originally submitted was adjusted.
      t.string  :IREDLC,    :limit => 1       # If the field contains anything other than ìR,î the students eligible for reduced-price lunch count originally submitted was adjusted.
      t.string  :ITOTFR,    :limit => 1       # If the field contains anything other than ìR,î the total of free lunch eligible and reduced-price lunch eligible count originally submitted was adjusted.
      t.string  :IMIGRN,    :limit => 1       # If the field contains anything other than ìR,î the migrant students enrolled in previous year count originally submitted was adjusted.
      t.string  :IPK,       :limit => 1       # If the field contains anything other than ìR,î the total prekindergarten students count originally submitted was adjusted.
      t.string  :IAMPKM,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAMPKF,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAMPKU,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IASPKM,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IASPKF,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IASPKU,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHIPKM,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHIPKF,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHIPKU,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBLPKM,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBLPKF,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBLPKU,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWHPKM,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWHPKF,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWHPKU,    :limit => 1       # If the field contains anything other than ìR,î the prekindergarten students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IKG,       :limit => 1       # If the field contains anything other than ìR,î the total kindergarten students count originally submitted was adjusted.
      t.string  :IAMKGM,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAMKGF,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAMKGU,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IASKGM,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IASKGF,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IASKGU,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHIKGM,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHIKGF,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHIKGU,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBLKGM,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBLKGF,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBLKGU,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWHKGM,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWHKGF,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWHKGU,    :limit => 1       # If the field contains anything other than ìR,î the kindergarten students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG01,      :limit => 1       # If the field contains anything other than ìR,î the total grade 1 students count originally submitted was adjusted.
      t.string  :IAM01M,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM01F,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM01U,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS01M,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS01F,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS01U,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students -  Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI01M,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI01F,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI01U,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL01M,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL01F,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL01U,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH01M,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH01F,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH01U,    :limit => 1       # If the field contains anything other than ìR,î the grade 1 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG02,      :limit => 1       # If the field contains anything other than ìR,î the total grade 2 students count originally submitted was adjusted.
      t.string  :IAM02M,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM02F,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM02U,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS02M,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS02F,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS02U,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI02M,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI02F,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI02U,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL02M,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL02F,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL02U,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH02M,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH02F,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH02U,    :limit => 1       # If the field contains anything other than ìR,î the grade 2 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG03,      :limit => 1       # If the field contains anything other than ìR,î the total grade 3 students count originally submitted was adjusted.
      t.string  :IAM03M,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM03F,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM03U,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS03M,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS03F,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS03U,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI03M,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI03F,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI03U,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL03M,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL03F,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL03U,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH03M,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH03F,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH03U,    :limit => 1       # If the field contains anything other than ìR,î the grade 3 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG04,      :limit => 1       # If the field contains anything other than ìR,î the total grade 4 students count originally submitted was adjusted.
      t.string  :IAM04M,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM04F,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM04U,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS04M,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS04F,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS04U,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI04M,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI04F,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI04U,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL04M,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL04F,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL04U,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH04M,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH04F,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH04U,    :limit => 1       # If the field contains anything other than ìR,î the grade 4 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG05,      :limit => 1       # If the field contains anything other than ìR,î the total grade 5 students count originally submitted was adjusted.
      t.string  :IAM05M,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM05F,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM05U,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS05M,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS05F,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS05U,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI05M,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI05F,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI05U,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL05M,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL05F,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL05U,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH05M,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH05F,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH05U,    :limit => 1       # If the field contains anything other than ìR,î the grade 5 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG06,      :limit => 1       # If the field contains anything other than ìR,î the total grade 6 students count originally submitted was adjusted.
      t.string  :IAM06M,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM06F,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM06U,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS06M,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS06F,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS06U,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI06M,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI06F,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI06U,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL06M,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL06F,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL06U,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH06M,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH06F,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH06U,    :limit => 1       # If the field contains anything other than ìR,î the grade 6 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG07,      :limit => 1       # If the field contains anything other than ìR,î the total grade 7 students count originally submitted was adjusted.
      t.string  :IAM07M,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM07F,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM07U,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS07M,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS07F,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS07U,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI07M,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI07F,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI07U,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL07M,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL07F,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL07U,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH07M,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH07F,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH07U,    :limit => 1       # If the field contains anything other than ìR,î the grade 7 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG08,      :limit => 1       # If the field contains anything other than ìR,î the total grade 8 students count originally submitted was adjusted.
      t.string  :IAM08M,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM08F,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM08U,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS08M,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS08F,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS08U,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI08M,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI08F,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI08U,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL08M,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL08F,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL08U,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH08M,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH08F,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH08U,    :limit => 1       # If the field contains anything other than ìR,î the grade 8 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG09,      :limit => 1       # If the field contains anything other than ìR,î the total grade 9 students count originally submitted was adjusted.
      t.string  :IAM09M,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM09F,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM09U,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS09M,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS09F,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS09U,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI09M,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI09F,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI09U,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL09M,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL09F,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL09U,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH09M,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH09F,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH09U,    :limit => 1       # If the field contains anything other than ìR,î the grade 9 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG10,      :limit => 1       # If the field contains anything other than ìR,î the total grade 10 students count originally submitted was adjusted.
      t.string  :IAM10M,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM10F,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM10U,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS10M,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS10F,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS10U,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI10M,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI10F,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI10U,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL10M,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL10F,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL10U,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH10M,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH10F,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH10U,    :limit => 1       # If the field contains anything other than ìR,î the grade 10 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG11,      :limit => 1       # If the field contains anything other than ìR,î the total grade 11 students count originally submitted was adjusted.
      t.string  :IAM11M,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM11F,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM11U,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS11M,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS11F,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS11U,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI11M,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI11F,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI11U,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL11M,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL11F,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL11U,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH11M,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH11F,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH11U,    :limit => 1       # If the field contains anything other than ìR,î the grade 11 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IG12,      :limit => 1       # If the field contains anything other than ìR,î the total grade 12 students count originally submitted was adjusted.
      t.string  :IAM12M,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAM12F,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAM12U,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IAS12M,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IAS12F,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IAS12U,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHI12M,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHI12F,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHI12U,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBL12M,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBL12F,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBL12U,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWH12M,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWH12F,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWH12U,    :limit => 1       # If the field contains anything other than ìR,î the grade 12 students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IUG,       :limit => 1       # If the field contains anything other than ìR,î the total ungraded students count originally submitted was adjusted.
      t.string  :IAMUGM,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAMUGF,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAMUGU,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IASUGM,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IASUGF,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IASUGU,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHIUGM,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Hispanic - male count originally submitted was adjusted.
      t.string  :IHIUGF,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Hispanic - female count originally submitted was adjusted.
      t.string  :IHIUGU,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBLUGM,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBLUGF,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBLUGU,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWHUGM,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWHUGF,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWHUGU,    :limit => 1       # If the field contains anything other than ìR,î the ungraded students - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IMEMB,     :limit => 1       # If the field contains anything other than ìR,î the total students, all grades count originally submitted was adjusted.
      t.string  :IAM,       :limit => 1       # If the field contains anything other than ìR,î one or more of the American Indian/Alaska Native student counts originally submitted was adjusted.
      t.string  :IAMALM,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - American Indian/Alaska Native - male count originally submitted was adjusted.
      t.string  :IAMALF,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - American Indian/Alaska Native - female count originally submitted was adjusted.
      t.string  :IAMALU,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - American Indian/Alaska Native - gender unknown count originally submitted was adjusted.
      t.string  :IASIAN,    :limit => 1       # If the field contains anything other than ìR,î one or more of the Asian/Pacific Islander student counts originally submitted was adjusted.
      t.string  :IASALM,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Asian/Pacific Islander - male count originally submitted was adjusted.
      t.string  :IASALF,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Asian/Pacific Islander - female count originally submitted was adjusted.
      t.string  :IASALU,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Asian/Pacific Islander - gender unknown count originally submitted was adjusted.
      t.string  :IHISP,     :limit => 1       # If the field contains anything other than ìR,î one or more of the Hispanic student counts originally submitted was adjusted.
      t.string  :IHIALM,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Hispanic - male count originally submitted was adjusted.
      t.string  :IHIALF,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Hispanic - female count originally submitted was adjusted.
      t.string  :IHIALU,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IBLACK,    :limit => 1       # If the field contains anything other than ìR,î one or more of the Black, non-Hispanic student counts originally submitted was adjusted.
      t.string  :IBLALM,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Black, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IBLALF,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Black, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IBLALU,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - Black, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IWHITE,    :limit => 1       # If the field contains anything other than ìR,î one or more of the White, non-Hispanic student counts originally submitted was adjusted.
      t.string  :IWHALM,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - White, non-Hispanic - male count originally submitted was adjusted.
      t.string  :IWHALF,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - White, non-Hispanic - female count originally submitted was adjusted.
      t.string  :IWHALU,    :limit => 1       # If the field contains anything other than ìR,î the total students, all grades - White, non-Hispanic - gender unknown count originally submitted was adjusted.
      t.string  :IETH,      :limit => 1       # If the field contains anything other than ìT,î one or more of the race/ethnicity student counts originally submitted was adjusted.
      t.string  :IPUTCH,    :limit => 1       # If the field contains anything other than ìT,î one or more of the pupil/teacher counts originally submitted was adjusted.
      t.string  :ITOTGR,    :limit => 1       # If the field contains anything other than ìT,î one or more of the grade totals originally submitted was adjusted.
    end
  end

  def self.down
    drop_table :portal_nces06_districts
    drop_table :portal_nces06_schools
  end

end
