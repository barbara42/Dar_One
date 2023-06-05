"""
Write a palatabiltiy matrix of size 50x50 to a csv file.
PALAT[X, Y] := rate at which predator Y eats prey X 
Goal: this file will be used to set up DAR1 runs
"""
using Plots
using DelimitedFiles

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
# TODO: make these functions, not hard-coded
# namelist helpers - > get predators 
# namelist helpers -> get size class of predator 
# get all organisms of size 1/10 that predator w/ offset 

predators = 24:47 # mixotrophs and zoo (c24 - c47)

# size class list, were size_class[i] = s, the size class of ci is s
# plankton ci eats size s-6. conversly, ci gets eaten by size classes s+6
# size classes change 10x with 6 offset (THANK GOD consistent)
size_class_list = [2, 3, 4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 
                    11, 12, 13, 14, 8, 9, 10, 11, 12, 13, 14, 15, 7, 8, 9, 10, 11,
                     12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 1, 2, 3] # manually entered 

# initialize everthing to 0
palat_matrix = zeros(50, 50)
# create a strict palat matrix
for predator in predators
    pred_size = size_class_list[predator]
    prey_size = pred_size - 6 
    # get all plankton that are this size 
    prey = findall(x->x==prey_size, size_class_list)
    for x in prey 
        palat_matrix[x, predator] = 1
    end
end

# write strict matrix to file 
file_name = "palat_matrix_strict.csv"
writedlm(file_name, palat_matrix, ",")

# initialize everthing to 0
palat_matrix = zeros(50, 50)
# create a flexible palat matrix
prey_size_range = [-3, -2, -1, 0, 1, 2, 3]
palat_range = [0.1, 0.2, 0.4, 1, 0.4, 0.2, 0.1]
for predator in predators
    pred_size = size_class_list[predator]
    prey_size = pred_size - 6 
    # get all plankton that are this size
    for i in eachindex(prey_size_range)
        offset = prey_size_range[i]
        prey = findall(x->x==prey_size + offset, size_class_list)
        for x in prey 
            palat_matrix[x, predator] = palat_range[i]
        end
    end 
end

# write flexible matrix to file 
file_name = "palat_matrix_flexible.csv"
writedlm(file_name, palat_matrix, ",")

plot_palat_matrix(palat_matrix, "Flexible Predator-Prey Palatability Matrix")


