#=
timer.jl
Utilities used in the Literate example
=#

using Statistics: median
using Base: gc_num, GC_Diff, timev_print
using Base: cumulative_compile_time_ns_before, cumulative_compile_time_ns_after


# cf https://github.com/JuliaLang/julia/blob/6aaedecc447e3d8226d5027fb13d0c3cbfbfea2a/base/timing.jl#L327-L362

"""
    @timeo
A version of `@time` that shows the timing only, not the computed values.
"""
macro timeo(ex) # @timeo macro to show only the timing, not results
    quote
        while false; end # compiler heuristic:
        local stats = gc_num()
        local compile_elapsedtime = cumulative_compile_time_ns_before()
        local elapsedtime = time_ns()
        local val = $(esc(ex))
        elapsedtime = time_ns() - elapsedtime
        compile_elapsedtime = cumulative_compile_time_ns_after() - compile_elapsedtime
        local diff = GC_Diff(gc_num(), stats)
        timev_print(elapsedtime, diff, compile_elapsedtime)
#       val
    end
end


"""
    btime()
Pretty-print the @benchmark output for non-interactive use with Literate.
"""
btime(t) = println(
    "time=", round(median(t.times)/10^6, digits=1), # median time in ms
    "ms mem=", t.memory,
    " alloc=", t.allocs,
)
