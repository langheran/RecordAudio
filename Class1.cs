using System;
using NAudio.Wave;
using RGiesecke.DllExport;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.IO;
using NAudio.Wave.SampleProviders;
using NAudio.CoreAudioApi;

namespace RecordAudio
{
    public class Class1
    {
        public Class1()
        {

        }
        public WasapiOut SilencePlayer = null;
        public WaveFileWriter LoopbackWriter = null;
        public WaveFileWriter MicrophoneWriter = null;
        public WasapiLoopbackCapture LoopbackCapture = null;
        public WaveInEvent MicrophoneCapture = null;
        public string outputFilePath = "";
        public string MicrophoneFilePath = "";
        public string LoopbackFilePath = "";

        [DllExport("Test", CallingConvention = CallingConvention.Cdecl)]
        public void Test()
        {
            MessageBox.Show("Test");
        }

        [DllExport("StartRecording", CallingConvention = CallingConvention.Cdecl)]
        public void StartRecording(string outputFilePath)
        {
            this.outputFilePath = outputFilePath;
            this.LoopbackFilePath = Path.Combine(Path.GetDirectoryName(this.outputFilePath), Path.GetFileNameWithoutExtension(this.outputFilePath) + "_i" + Path.GetExtension(this.outputFilePath));
            this.MicrophoneFilePath = Path.Combine(Path.GetDirectoryName(this.outputFilePath), Path.GetFileNameWithoutExtension(this.outputFilePath) + "_m" + Path.GetExtension(this.outputFilePath));
            // Redefine the capturer instance with a new instance of the LoopbackCapture class
            this.LoopbackCapture = new WasapiLoopbackCapture();
            this.SilencePlayer = new WasapiOut(WasapiLoopbackCapture.GetDefaultLoopbackCaptureDevice(), AudioClientShareMode.Shared, false, 100);
            this.SilencePlayer.Init(new SilenceProvider(LoopbackCapture.WaveFormat));
            this.SilencePlayer.Play();

            // Redefine the audio writer instance with the given configuration
            this.LoopbackWriter = new WaveFileWriter(this.LoopbackFilePath, LoopbackCapture.WaveFormat);

            // When the capturer receives audio, start writing the buffer into the mentioned file
            this.LoopbackCapture.DataAvailable += (s, a) =>
            {
                this.LoopbackWriter.Write(a.Buffer, 0, a.BytesRecorded);
            };

            // When the Capturer Stops
            this.LoopbackCapture.RecordingStopped += (s, a) =>
            {
                this.LoopbackWriter.Close();
                this.LoopbackWriter.Dispose();
                this.LoopbackWriter = null;
                this.SilencePlayer.Stop();
                LoopbackCapture.Dispose();
            };

            // Start recording !
            this.LoopbackCapture.StartRecording();

            this.MicrophoneCapture = new WaveInEvent();
            this.MicrophoneCapture.DeviceNumber = 0;
            this.MicrophoneCapture.WaveFormat = LoopbackCapture.WaveFormat;
            this.MicrophoneCapture.BufferMilliseconds = 50;
            this.MicrophoneWriter = new WaveFileWriter(this.MicrophoneFilePath, LoopbackCapture.WaveFormat);
            this.MicrophoneCapture.DataAvailable += (s, a) =>
            {
                this.MicrophoneWriter.Write(a.Buffer, 0, a.BytesRecorded);
            };
            this.MicrophoneCapture.RecordingStopped += (s, a) =>
            {
                this.MicrophoneWriter.Close();
                this.MicrophoneWriter.Dispose();
                this.MicrophoneWriter = null;
                MicrophoneCapture.Dispose();
            };
            MicrophoneCapture.StartRecording();
        }

        [DllExport("StopRecording", CallingConvention = CallingConvention.Cdecl)]
        public void StopRecording()
        {
            // Stop recording !
            this.LoopbackCapture.StopRecording();
            this.MicrophoneCapture.StopRecording();
            while (this.MicrophoneWriter != null || this.LoopbackWriter != null)
            { }
            using (var loopbackReader = new AudioFileReader(this.LoopbackFilePath))
            using (var microphoneReader = new AudioFileReader(this.MicrophoneFilePath))
            {
                var mixer = new MixingSampleProvider(new[] { loopbackReader, microphoneReader });
                WaveFileWriter.CreateWaveFile16(this.outputFilePath, mixer);
            }
            if (File.Exists(this.LoopbackFilePath))
                File.Delete(this.LoopbackFilePath);
            if (File.Exists(this.MicrophoneFilePath))
                File.Delete(this.MicrophoneFilePath);
        }
    }
}
