import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: page

    property alias cfg_fontPercent: fontPercentSpin.value
    property int cfg_boxSize: Plasmoid.configuration.boxSize
    property int cfg_radiusPercent: Plasmoid.configuration.radiusPercent
    property alias cfg_wrapScrolling: wrapScroll.checked

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Text")
        }

        QQC2.SpinBox {
            id: fontPercentSpin
            Kirigami.FormData.label: i18n("Number size:")
            from: 30
            to: 90
            stepSize: 5
            textFromValue: (value, locale) => i18n("%1% of box", value)
            valueFromText: (text, locale) => parseInt(text)
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Appearance")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Box size:")

            QQC2.SpinBox {
                id: sizeSpin
                enabled: !sizeAuto.checked
                from: 16
                to: 128
                stepSize: 2
                textFromValue: (value, locale) => i18n("%1 px", value)
                valueFromText: (text, locale) => parseInt(text) || 0
                onValueModified: page.cfg_boxSize = value
            }

            QQC2.CheckBox {
                id: sizeAuto
                text: i18n("Auto (fit panel)")
                onToggled: page.cfg_boxSize = checked ? 0 : sizeSpin.value
            }

            Component.onCompleted: {
                sizeAuto.checked = page.cfg_boxSize === 0;
                sizeSpin.value = page.cfg_boxSize > 0 ? page.cfg_boxSize : 36;
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Corner radius:")

            QQC2.Slider {
                id: radiusSlider
                from: 0
                to: 50
                stepSize: 1
                Layout.preferredWidth: Kirigami.Units.gridUnit * 10
                onMoved: page.cfg_radiusPercent = value
                Component.onCompleted: value = page.cfg_radiusPercent
            }

            QQC2.Label {
                text: radiusSlider.value === 50
                    ? i18n("50% (circle)") : i18n("%1%", radiusSlider.value)
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Behavior")
        }

        QQC2.CheckBox {
            id: wrapScroll
            Kirigami.FormData.label: i18n("Scrolling:")
            text: i18n("Wrap around past the ends")
        }
    }
}
