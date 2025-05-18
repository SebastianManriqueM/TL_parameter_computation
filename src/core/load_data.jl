# include("definitions.jl")

function load_transmission_line_db( )
    #Read data from XLSX file (Geometries, T Lines, Conductors, etc) 
    file_rel_path      = "src/data/Tower_geometries_DB.xlsx"
    sheet_tl_geometry  = "TL_Geometry"
    sheet_us_states    = "Neighboring"
    sheet_conductors   = "Conductors"
    sheet_ground_wires = "G_wire"
    sheet_tl_dataset   = "TL_dataset"

    #Load Data
    df_tl_geometry     = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_geometry) )
    df_us_states_info  = DataFrame( XLSX.readtable(file_rel_path, sheet_us_states) )
    df_conductors      = DataFrame( XLSX.readtable(file_rel_path, sheet_conductors) )
    df_ground_wires    = DataFrame( XLSX.readtable(file_rel_path, sheet_ground_wires) )
    df_tl_examples     = DataFrame( XLSX.readtable(file_rel_path, sheet_tl_dataset) )

    return (df_tl_geometry, df_us_states_info, df_conductors, df_ground_wires, df_tl_examples)
end
