ffmpeg -i record_0001.mp3 -ss 0 -t 1800 first-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 1800 -t 1800 second-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 3600 -t 1800 third-30-min.mp3