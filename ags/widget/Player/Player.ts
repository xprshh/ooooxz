import type Gtk from "gi://Gtk?version=3.0"
import { Media } from "widget/quicksettings/widgets/Media"
import PopupWindow from "widget/PopupWindow"
import options from "options"

const { bar, datemenu } = options
const media = (await Service.import("mpris")).bind("players")
const layout = Utils.derive([bar.position, datemenu.position], (bar, qs) =>
    `${bar}-${qs}` as const,
)

const Settings = () => Widget.Box({
    vertical: true,
    class_name: "quicksettings vertical",
    //css: bar.media.length.bind().as(w => `min-width: ${w}px;`),
    css: "min-width: 400px;",
    children: [
        Widget.Box({
            visible: media.as(l => l.length > 0),
            child: Media(),
        }),
    ],
})

const Player = () => PopupWindow({
    name: "player",
    exclusivity: "exclusive",
    transition: bar.position.bind().as(pos => pos === "top" ? "slide_down" : "slide_up"),
    layout: layout.value,
    child: Settings(),
})

export function setupPlayer() {
    App.addWindow(Player())
    layout.connect("changed", () => {
        App.removeWindow("player")
        App.addWindow(Player())
    })
}
