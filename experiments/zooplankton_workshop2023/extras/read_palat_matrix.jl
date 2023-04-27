include("../../../src/DarOneTools.jl")
using .DarOneTools
using DelimitedFiles, Plots

"""
Plot a palatability matrix 
"""
function plot_palat_matrix(palat_matrix, title="Predator-Prey Palatability Matrix")
    # heatmap(palat_matrix', color=palette(:viridis, 10))
    heatmap(palat_matrix')
    heatmap!(xlabel="prey")
    heatmap!(ylabel="predator")
    plot!(colorbar_title="palatability")
    plot!(title=title)
end

"""
read_palat_matrix(config_obj)

returns an NxN matrix, where element at (X, Y) indicates the rate at which predator Y eats prey X
"""
function read_palat_matrix(fil, num_species=50)
    file_name = "data.traits"
    group_name = "DARWIN_TRAITS"
    #rundir = joinpath(config_obj.folder, config_obj.ID, "run")
    # read the contents of the data file into a namelist 
    data_file = file_name
    # TODO uncomment after testing
    #fil = joinpath(rundir, data_file)
    nml = read(fil, MITgcm_namelist())
    # which param group do you want to modify?
    nmlgroup = group_name
    group_idx =findall(nml.groups.==Symbol(nmlgroup))[1]
    parms = nml.params[group_idx]

    # print(typeof(parms))
    # print(parms)

    palat_dic = Dict()
    for key in keys(parms)
        if occursin("PALAT(", String(key)) 
            value = parms[key]
            # trim out whitespaces
            key = replace(String(key), " " => "")
            println(key)
            i = findfirst("(", key)
            j = findfirst("(", key)
            X = key[findfirst("(", key)[1]+1: findfirst(",", key)[1]-1]
            Y = key[findfirst(",", key)[1]+1: findlast(")", key)[1]-1]
            println(X, " ", Y)
            new_key = (X, Y)
            palat_dic[new_key] = value 
        end
    end

    # note: PALAT(X,Y) := rate at which predator Y eats prey X 
    palat_matrix = zeros(num_species,num_species)
    for key in keys(palat_dic)
        x = parse(Int, key[1])
        y = parse(Int, key[2])
        value = palat_dic[key]
        palat_matrix[x,y] = value 
    end
    return palat_matrix
end 

fil = "/Users/birdy/Documents/eaps_research/darwin3/verification/dar1_1D_31+32+3/input/data.traits"
num_species = 66
palat_matrix = read_palat_matrix(fil, num_species)
file_name = "z32_PALAT.csv"
writedlm(file_name, palat_matrix, ",")
plot_palat_matrix(palat_matrix, "z32_PALAT Predator-Prey Palatability Matrix")
# TODO: write to file as z32_PALAT


fil = "/Users/birdy/Documents/eaps_research/julia stuff/Dar_One/experiments/zooplankton_workshop2023/extras/data.traits_thirtieth"
num_species = 66
palat_matrix = read_palat_matrix(fil, num_species)
file_name = "z32_PALAT_1_30.csv"
writedlm(file_name, palat_matrix, ",")
plot_palat_matrix(palat_matrix, "z32_PALAT_thirtieth Predator-Prey Palatability Matrix")
# TODO: write to file as z32_PALAT_1_30


fil = "/Users/birdy/Documents/eaps_research/julia stuff/Dar_One/experiments/zooplankton_workshop2023/extras/data.traits_double"
num_species = 66
palat_matrix = read_palat_matrix(fil, num_species)
file_name = "z32_PALAT_2_1.csv"
writedlm(file_name, palat_matrix, ",")
plot_palat_matrix(palat_matrix, "z32_PALAT Predator-Prey Palatability Matrix")
# TODO: write to file as z32_PALAT_2_1
