using Test

const ROOT = normpath(joinpath(@__DIR__, ".."))
const DARWIN = abspath(get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3"))
const CONFIG_ROOT = joinpath(DARWIN, "verification", "dar_one_config")
const RUN_ROOT = joinpath(CONFIG_ROOT, "run")
const RUN_SUFFIX = "-test-$(getpid())-$(time_ns())"

# The examples compile Darwin and modify its configuration source files.
for path in (joinpath(DARWIN, "tools", "genmake2"),
             joinpath(CONFIG_ROOT, "code", "SIZE.h"),
             joinpath(CONFIG_ROOT, "code", "darwin_plankton.F"),
             joinpath(CONFIG_ROOT, "build"),
             joinpath(CONFIG_ROOT, "input"))
    ispath(path) || error("Darwin installation is missing $path. Set DARONE_MITGCM_PATH to a Darwin checkout containing dar_one_config.")
end

for program in ("make", "gfortran")
    Sys.which(program) === nothing && error("The example tests require $program on PATH.")
end

function run_example(script, environment)
    cmd = Cmd(`$(Base.julia_cmd()) --startup-file=no --project=$ROOT $(joinpath(ROOT, script))`; dir=ROOT)
    @info "Running $script"
    log_dir = get(ENV, "DARONE_EXAMPLE_LOG_DIR", joinpath(tempdir(), "darone-example-logs-$(getpid())"))
    mkpath(log_dir)
    log_file = joinpath(log_dir, replace(script, '/' => '_') * ".log")
    succeeded = open(log_file, "w") do log
        success(pipeline(addenv(cmd, environment...), stdout=log, stderr=log))
    end
    if !succeeded
        println(stderr, "Example failed: $script (log: $log_file)")
        lines = readlines(log_file)
        for line in lines[max(1, length(lines)-79):end]
            println(stderr, line)
        end
    end
    return succeeded
end

function check_simulation(name)
    rundir = joinpath(RUN_ROOT, name * RUN_SUFFIX, "run")
    @test isdir(rundir)
    isdir(rundir) || return

    output_dirs = [joinpath(rundir, f) for f in readdir(rundir)
                   if startswith(f, "ecco_gud_") && isdir(joinpath(rundir, f))]
    logs = [joinpath(rundir, f) for f in readdir(rundir)
            if f == "STDOUT.0000" || (startswith(f, "thread-") && endswith(f, "-output.txt"))]
    append!(logs, [joinpath(d, "STDOUT.0000") for d in output_dirs
                   if isfile(joinpath(d, "STDOUT.0000"))])

    @test !isempty(logs)
    @test any(f -> occursin("Execution ended Normally", read(f, String)), logs)

    diagnostics = [joinpath(d, f) for d in output_dirs for f in readdir(d)
                   if startswith(f, "3d.") && endswith(f, ".nc")]
    @test !isempty(diagnostics)
    @test all(f -> filesize(f) > 0, diagnostics)
end

function run_case_study(build_script, run_script, names, environment)
    built = run_example(build_script, environment)
    @test built
    built || return
    ran = run_example(run_script, environment)
    @test ran
    ran || return
    foreach(check_simulation, names)
end

plot_dir = get(ENV, "DARONE_EXAMPLE_PLOT_DIR", joinpath(tempdir(), "darone-example-plots-$(getpid())"))
mkpath(plot_dir)

@testset "Documentation image references" begin
    source_dir = joinpath(ROOT, "docs", "src")
    references = Set{String}()
    for file in filter(f -> endswith(f, ".md"), readdir(source_dir; join=true))
        for match in eachmatch(r"!\[[^\]]*\]\((images/[^)]+)\)", read(file, String))
            push!(references, match.captures[1])
        end
    end
    @test !isempty(references)
    for reference in references
        image = joinpath(source_dir, reference)
        @test isfile(image) && filesize(image) > 0
    end
end

mktempdir() do data_dir
    generated_dir = joinpath(plot_dir, "generated")
    mkpath(generated_dir)
    plot_file = joinpath(generated_dir, "beginner_tutorial.png")
    environment = [
        "DARONE_MITGCM_PATH" => DARWIN,
        "DARONE_DATA_DIR" => data_dir,
        "DARONE_EXAMPLE_ITERATIONS" => get(ENV, "DARONE_EXAMPLE_ITERATIONS", "12"),
        "DARONE_EXAMPLE_ID_SUFFIX" => RUN_SUFFIX,
        "DARONE_PLOT_FILE" => plot_file,
        "DARONE_EXAMPLE_PLOT_DIR" => plot_dir,
        "GKSwstype" => "100",
    ]

    @testset "DarOne tutorials and case studies" begin
        @testset "Beginner tutorial" begin
            built = run_example("beginner_tutorial/1_build_example.jl", environment)
            @test built
            if built
                ran = run_example("beginner_tutorial/2_run_example.jl", environment)
                @test ran
                if ran
                    check_simulation("beginner_tutorial-pro-syn-2")
                    @test run_example("beginner_tutorial/3_plotting_example.jl", environment)
                    @test isfile(plot_file) && filesize(plot_file) > 0
                end
            end
        end

        @testset "Case-study input data" begin
            @test run_example("test/resources/generate_example_fixtures.jl", environment)
            for name in ("3d.nc", "tave.nc", "par.nc")
                @test isfile(joinpath(data_dir, name)) && filesize(joinpath(data_dir, name)) > 0
            end
        end

        @testset "Bottle experiment" begin
            bottle_environment = [key == "DARONE_EXAMPLE_ITERATIONS" ? key => "56" : key => value
                                  for (key, value) in environment]
            run_case_study("case_studies/bottle_experiment_build.jl",
                           "case_studies/bottle_experiment_run.jl",
                           ["bottle-$treatment-203-109" for treatment in ("control", "with-no3", "with-nh4")],
                           bottle_environment)
        end

        @testset "Global steady state" begin
            names = ["globe-ss-$(x[1])-$(x[2])-$(y[1])-$(y[2])" for x in ((1, 90), (91, 180), (181, 270), (271, 360))
                                      for y in ((1, 40), (41, 80), (81, 120), (121, 160))]
            run_case_study("case_studies/global_steadystate_build.jl",
                           "case_studies/global_steadystate_run.jl", names, environment)
        end

        @testset "Nitrogen fixers" begin
            run_case_study("case_studies/nitrogen_fixers_build.jl",
                           "case_studies/nitrogen_fixers_run.jl", ["n_30x30"], environment)
        end

        @testset "Example plots" begin
            @test run_example("test/resources/plot_example_outputs.jl", environment)
            for name in ("bottle_experiment_ci.png", "Fig_Bray_Curtis_ci.png", "NfixerPhase_ci.png")
                file = joinpath(generated_dir, name)
                @test isfile(file) && filesize(file) > 0
            end
            @info "Example plots saved in $plot_dir"
        end
    end
end
