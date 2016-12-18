using UnityEngine;
using UnityEngine.UI;

namespace MusicPlayer
{
    public class Sample : MonoBehaviour
    {
        public Text infoLabel;

        void OnEnable()
        {
            MusicPlayerPlugin.Instance.OnPlayingItemChanged += OnPlayingItemChanged;
        }


        void OnDisable()
        {
            MusicPlayerPlugin.Instance.OnPlayingItemChanged -= OnPlayingItemChanged;
        }

        void Update()
        {
            var info = MusicPlayerPlugin.Instance.info;
            double currentTime = MusicPlayerPlugin.Instance.CurrentTime;

            infoLabel.text = string.Format(@"Info
title:{0}
artist:{1}
album:{2}
duration:{3}
current time:{4}", info.title, info.artist, info.album, info.duration, info.currentTime);
        }

        void OnPlayingItemChanged(MusicPlayer.Info info)
        {
            Debug.Log(info);
        }

        public void OnPlay()
        {
            Debug.Log("OnPlay");
            MusicPlayerPlugin.Instance.Play();
        }

        public void OnLoad()
        {
            Debug.Log("OnLoad");
            MusicPlayerPlugin.Instance.Load();
        }
    }
}