{:user {:jvm-opts ^:replace ["-Xmx2096M"]
        :plugins [[lein-ancient "0.6.15"]
                  ;; confuses doo test runner
                  #_[venantius/ultra "0.6.0"]]}}
