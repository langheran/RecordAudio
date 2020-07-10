ffmpeg -i record_0001.mp3 -ss 0 -t 1800 first-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 1800 -t 1800 second-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 3600 -t 1800 third-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 5400 -t 1800 fourth-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 7200 -t 1800 fifth-30-min.mp3
ffmpeg -i record_0001.mp3 -ss 9000 -t 1800 sixth-30-min.mp3