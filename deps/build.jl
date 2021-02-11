# Download links in `assets.csv`

dir = joinpath(@__DIR__, "Pluto", "frontend", "offline_assets")
mkpath(dir)

for url in readlines(joinpath(@__DIR__, "assets.csv") )
    @info "Downloading: $url"
    file = touch(dir, basename(url))
    download(url, file)
end