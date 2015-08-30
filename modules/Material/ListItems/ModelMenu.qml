/*
 * QML Material - An application framework implementing Material Design.
 * Copyright (C) 2015 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1

/*!
   \qmltype ModelMenu
   \inqmlmodule Material.ListItems 0.1

   \brief A list item that opens a dropdown menu when tapped. Supports ListModel, array of objects, array of strings, role names.
 */
Subtitled {
    id: listItem

    property var model
    property alias selectedIndex: listView.currentIndex
    property var selectedValue: getModelByIndex(listView.currentIndex)
    property string textRole: 'text'
    property string iconNameRole: 'iconName'
    property string dividerRole: 'divider'
    property string disabledRole: 'disabled'

    subText: listView.currentItem.text ? listView.currentItem.text : ''

    onClicked: menu.open(listItem, Units.dp(16), 0)

    property int __maxWidth: 0
    property bool __isStringModel: true
    property bool __hasIcons: false

    function getModelByIndex(idx) {
        return model.get ? model.get(idx) : model[idx];
    }

    Label {
        id: hiddenLabel
        style: "subheading"
        visible: false

        onContentWidthChanged: {
            // magic 100 and 33 pixels - in case of contains icons or not
            __maxWidth = Math.max(contentWidth + Units.dp(__hasIcons ? 100 : 33), __maxWidth)
        }
    }

    onModelChanged: {
        var longestString = 0;
        var len = model.length || model.count;
        __isStringModel = len > 0 ? typeof model[0] === 'string' : true
        for (var i = 0; i < len; i++) {
            var data = getModelByIndex(i);
            if (data) {
                var txt = __isStringModel ? data : data[textRole];
                if (txt && txt.length > longestString)
                {
                    longestString = txt.length
                    hiddenLabel.text = txt
                }
                if (!__hasIcons && data[iconNameRole] && data[iconNameRole] !== '') __hasIcons = true;
            }
        }
    }

    Dropdown {
        id: menu

        anchor: Item.TopLeft

        width: Math.max(Units.dp(56 * 2), Math.min(listItem.width - Units.dp(32), __maxWidth))
        height: listView.height + Units.dp(16)

        Rectangle {
            anchors.fill: parent
            radius: Units.dp(2)
        }

        ListView {
            id: listView

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: Units.dp(8)
            }

            interactive: false
            height: count > 0 ? contentHeight : 0
            model: listItem.model

            delegate: Item {
                property string text: stardardItem.text
                width: listView.width
                height: stardardItem.visible ? stardardItem.height : dividerItem.height
                Standard {
                    id: stardardItem

                    visible: {
                        if (__isStringModel) return typeof modelData !== 'undefined' && modelData !== null;
                        if (typeof modelData !== 'undefined') {
                            if (modelData === null) return false;
                            else if (dividerRole in modelData) return modelData[dividerRole] !== true;
                        }
                        else if (dividerRole in model) return model[dividerRole] !== true;
                        return true;
                    }

                    iconColor: '#000000'
                    iconName: {
                        if (__isStringModel) return '';
                        if (typeof modelData !== 'undefined' && modelData && iconNameRole in modelData) return modelData[iconNameRole];
                        else if (model[iconNameRole]) return model[iconNameRole];
                        else __hasIcons ? 'image/empty' : '';
                    }
                    text: {
                        if (__isStringModel) return modelData || '';
                        if (typeof modelData !== 'undefined' && modelData && textRole in modelData) return modelData[textRole];
                        else if (model[textRole]) return model[textRole];
                        else return '';
                    }
                    enabled: {
                        if (__isStringModel) return true;
                        if (typeof modelData !== 'undefined' && modelData && disabledRole in modelData) return modelData[disabledRole] !== true;
                        else if (model[disabledRole]) return model[disabledRole] !== true;
                        else return true;
                    }

                    onClicked: {
                        listView.currentIndex = index
                        menu.close()
                    }
                }
                Divider {
                    id: dividerItem
                    visible: !stardardItem.visible
                }
            }
        }
    }
}
