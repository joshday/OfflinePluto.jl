# Download links in `assets.csv`

dir = joinpath(@__DIR__, "Pluto", "frontend", "offline_assets")
rm(dir, force=true, recursive=true)
mkpath(dir)

for url in readlines(joinpath(@__DIR__, "assets.csv") )
    @info "Downloading: $url"
    file = touch(joinpath(dir, basename(url)))
    download(url, file)
end