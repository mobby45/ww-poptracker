function fw_access()
    return (has("grapple") and has("leaf") and has ("magic") and has("windwaker") and has("requiem"))
end

function totg_access()
    return (has("din") and has("farore") and has("nayru"))
end

function et_access()
    return (has("power") and has("windwaker") and has("melody"))
end

function wt_access()
    return (has("boots") and has("hammer") and has("windwaker") and has("melody"))
end

function can_fly()
    return (has("leaf") and has("magic"))
end

function can_magicarrow()
    return (has("bow_2") and has("magic"))
end

function can_lightarrow()
    return (has("bow_3") and has("magic"))
end

function can_change_wind()
    return (has("windwaker") and has("requiem"))
end

function can_play_song_of_passing()
    return (has("windwaker") and has("passing"))
end

function can_play_ballad_of_gales()
    return (has("windwaker") and has("ballad"))
end

function can_destroy_cannons()
    return (has("boomerang") or has("bombs"))
end

function can_cut_grass()
    return (has("hammer") or has("boomerang") or has("bombs") or has("sword"))
end

function can_cut_trees()
    return (has("sword") or has("boomerang") or has("hammer"))
end

function can_remove_rocks()
    return (has("power") or has("bombs"))
end

function can_defeat_seahats()
    return (has("boomerang")) or (has("bow")) or (has("hookshot")) or (has("bombs"))
end