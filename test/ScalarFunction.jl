using Test, FixedPointToolkit, LinearAlgebra

"""
Lets find the fixed point of f(x) = cos(x) using three different methods.
"""

guess                  =   rand()
mixingAlpha            =   0.5   

selfcons               =   SelfCons(cos, SimpleMixing   , guess; Update_kwargs = Dict(:alpha => mixingAlpha))
selfcons_scheduled     =   SelfCons(cos, ScheduledMixing, guess; Update_kwargs = Dict(:alpha => mixingAlpha, :Scheduler => QuadraticScheduling))
selfcons_broyden       =   SelfCons(cos, BroydenMixing  , guess; Update_kwargs = Dict(:alpha => mixingAlpha, :B => mixingAlpha * Matrix(1.0I, 1, 1) ))

tol                    =   1e-8

FixedPoint!(selfcons          ; tol = tol, max_iter = 100)
FixedPoint!(selfcons_scheduled; tol = tol, max_iter = 100)
FixedPoint!(selfcons_broyden  ; tol = tol, max_iter = 100)

@test norm(cos(selfcons.VIns[end]) - selfcons.VIns[end]) < tol
@test norm(cos(selfcons_scheduled.VIns[end]) - selfcons_scheduled.VIns[end]) < tol
@test norm(cos(selfcons_broyden.VIns[end]) - selfcons_broyden.VIns[end]) < tol
