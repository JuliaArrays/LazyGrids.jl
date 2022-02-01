#=
timer.jl
Utilities used in the Literate example
=#

using Statistics: median
using Base: gc_num, gc_alloc_count, GC_Diff, timev_print
using Base: cumulative_compile_time_ns_before, cumulative_compile_time_ns_after


# cf https://github.com/JuliaLang/julia/blob/6aaedecc447e3d8226d5027fb13d0c3cbfbfea2a/base/timing.jl#L327-L362

"""
    @timeo
A version of `@time` that shows the timing only, not the computed values.
Returns a string so that Literate will capture the output.
"""
macro timeo(ex) # @timeo macro to show only the timing, not results
    quote
        while false; end # compiler heuristic:
        local stats = gc_num()
#       local compile_time = cumulative_compile_time_ns_before()
        local elapsedtime = time_ns()
        local val = $(esc(ex))
        elapsedtime = time_ns() - elapsedtime
#       compile_time = cumulative_compile_time_ns_after() - compile_time
        local diff = GC_Diff(gc_num(), stats)
        local allocs = gc_alloc_count(diff)
#       timev_print(elapsedtime, diff, compile_elapsedtime)
#       time_print(elapsedtime, diff.allocd, diff.total_time, allocs, compile_time, true)
        string(
            "time=", round(elapsedtime/10^6, digits=1), # time in ms
            "ms mem=", diff.allocd,
            " alloc=", allocs,
        )
    end
end


"""
    btime(t ; scale, digits)
Pretty-print the @benchmark output for non-interactive use with Literate.
Returns a string so that Literate will capture the output.
* `scale` is `10^6` by default, for reporting in ms.  Use `10^3` for μs.
* `digits` is 1 by default.
"""
btime(t; scale::Real=10^6, digits::Int=1) = string(
    "time=", round(median(t.times)/scale; digits), # median time in ms
    "ms mem=", t.memory,
    " alloc=", t.allocs,
)
