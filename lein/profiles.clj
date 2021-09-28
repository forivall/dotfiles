{:user
 {:plugins [[mvxcvi/whidbey "2.2.1"]]
  :middleware [whidbey.plugin/repl-pprint]
  :whidbey
  {:width 120
   :map-delimiter ","
   :extend-notation true
   :print-color true
   :print-meta true
   :color-scheme {:boolean [:yellow]
                  :character [:bold :green]
                  :class-delimiter [:bold :blue]
                  :class-name [:blue]
                  :delimiter [:cyan]
                  :function-symbol [:blue]
                  :keyword [:red]
                  :nil [:yellow]
                  :number [:yellow]
                  :string [:green]
                  :symbol nil
                  :tag [:red]}}}}
