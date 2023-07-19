module FixedPointToolkit

    include("Scheduler.jl")
    using .Scheduler
    export QuadraticScheduling, ExponentialScheduling

    include("Updates.jl")
    using .Updates
    export SimpleMixing, ScheduledMixing, BroydenMixing

    include("SelfCons.jl")
    using .SelfConsistency
    export SelfCons

    include("Checkpointer.jl")
    using .Checkpointer
    export save_checkpoint, read_checkpoint, ReCreateSelfCons

    include("FixedPoint.jl")
    using .FPoint
    export FixedPoint!, ContinueFixedPoint!

    include("PlotSelfCons.jl")
    using .PlotSelfCons
    export Plot_History

end # module FixedPointToolkit
