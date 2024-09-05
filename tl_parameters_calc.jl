#=
Alabama Alabama	Ala.	AL
Alaska Alaska	Alaska	AK
Arizona Arizona	Ariz.	AZ
Arkansas Arkansas	Ark.	AR
California California	Calif.	CA
 Colorado	Colo.	CO
 Connecticut	Conn.	CT
Delaware Delaware	Del.	DE
Washington, D.C. District of Columbia	D.C.	DC
Florida Florida	Fla.	FL
Georgia (U.S. state) Georgia	Ga.	GA
Hawaii Hawaii	Hawaii	HI
Idaho Idaho	Idaho	ID
Illinois	Ill.	IL
Indiana	Ind.	IN
Iowa	Iowa	IA
Kansas	Kans.	KS
Kentucky	Ky.	KY
Louisiana	La.	LA
Maine	Maine	ME
Maryland	Md.	MD
Massachusetts	Mass.	MA
Michigan	Mich.	MI
Minnesota	Minn.	MN
Mississippi	Miss.	MS
Missouri	Mo.	MO
Montana	Mont.	MT
Nebraska	Nebr.	NE
Nevada	Nev.	NV
New Hampshire	N.H.	NH
New Jersey	N.J.	NJ
New Mexico	N. Mex.	NM
New York	N.Y.	NY
North Carolina	N.C.	NC
North Dakota	N. Dak.	ND
Ohio	Ohio	OH
Oklahoma	Okla.	OK
Oregon	Ore.	OR
Pennsylvania	Pa.	PA
Rhode Island	R.I.	RI
South Carolina	S.C.	SC
South Dakota	S. Dak.	SD
Tennessee	Tenn.	TN
Texas	Tex.	TX
Utah	Utah	UT
Vermont	Vt.	VT
Virginia	Va.	VA
Washington	Wash.	WA
West Virginia	W. Va.	WV
Wisconsin Wisconsin	Wis.	WI
Wyoming Wyoming	Wyo.	WY
=#

using XLSX
using DataFrames

const DATA_SET_TL_VOLTAGES = [345 500 735]

mutable struct TL_FILTERS
    voltage_kv::Int
    n_circuits::Int
    n_ground_wire::Int
    state::String
    structure_type::String
end

function check_voltage_availability( value )
    for element in DATA_SET_TL_VOLTAGES
        if element == value
            return true
        end
    end
    return false
end

function get_filtered_tl_dataframe(df::DataFrame, user_filter::TL_FILTERS)
    # Voltage level
    if !(check_voltage_availability( user_filter.voltage_kv ))
        error("The current data set does not include information of Tower Geometries for $(user_filter.voltage_kv) kV. The dataset includes information for the following voltage levels (kV): $DATA_SET_TL_VOLTAGES")
    end
    filt_df  = filter( row -> row[:voltage_kv] == user_filter.voltage_kv, df) 

    if nrow(filt_df) < 2
        @warn( "Currently, there is only one data for $(user_filter.voltage_kv). Other filters were neglected" )
        return filt_df
    end

    #N circuits
    if user_filter.n_circuits > 2
        error("Currently, there is only one data for transmission lines carrying up to 2 circuits")
    end

    filt_df2   = filter(row -> row[:n_circuits] == user_filter.n_circuits, filt_df)
    if nrow(filt_df2) < 1
        @warn( "Currently there are no data that match for voltage level of $(user_filter.voltage_kv) and number of circuits of $(user_filter.n_circuits). The number of circuits filter was ignored" )
        return filt_df
    end
    filt_df = filt_df2

    #N ground wires
    if nrow(filt_df) < 2
    filt_df2   = filter(row -> row[:n_ground_w] == user_filter.n_ground_wire, filt_df)
    end

    #State
    if !(user_filter.state == "")
        filt_df   = filter(row -> occursin( user_filter.state, coalesce(row[:state], "") ), filt_df)
    end

    #Structure type
    if !(user_filter.structure_type == "")
        filt_df   = filter(row -> row[:structure_type] == user_filter.structure_type, filt_df)
    end

    return filt_df
end




#Read XLSX file with typical US tower Geometries
file_path  = "Tower_geometries_DB.xlsx"
sheet_name = "TL_Geometry"
df         = DataFrame( XLSX.readtable(file_path, sheet_name) )
tl1_filter = TL_FILTERS( 345, 2, 2, "Indiana", "" )

filt_df    = get_filtered_tl_dataframe(df, tl1_filter)

println(filt_df)
println("\n", nrow(filt_df))
