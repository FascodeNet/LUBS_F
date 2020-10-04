/* === This file is part of Calamares - <http://github.com/calamares> ===
 *
 *   Copyright 2015, Teo Mrnjavac <teo@kde.org>
 *
 *   Calamares is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Calamares is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Slides images dimensions are 800x440px.
 */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    
    Slide {
        Image {
            id: background
            source: "logo-512.png"
            width: 200; height: 200
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            id: textkun
            anchors.horizontalCenter: background.horizontalCenter
            anchors.top: background.bottom
            text: "Installing now...."
            wrapMode: Text.WordWrap
            width: presentation.width
            horizontalAlignment: Text.Center
        }

    SequentialAnimation{
        SequentialAnimation{
            ParallelAnimation {
                YAnimator {
                    target: imageleft
                    from: imageleft.y
                    to: imageleft.y * 4.8
                    easing.type: Easing.OutExpo;
                    duration: 300
                }
            }
            ParallelAnimation {
                YAnimator {
                    target: imageleft;
                    from: imageleft.y * 4.8
                    to: imageleft.y
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
            }
        }
        PauseAnimation { duration: 1100 }
        running: true
        loops: Animation.Infinite
    }
    SequentialAnimation{
        PauseAnimation { duration: 300 }
        SequentialAnimation{
            ParallelAnimation {
                YAnimator {
                    target: imagecenter
                    from: imageleft.y
                    to: imageleft.y * 4.8
                    easing.type: Easing.OutExpo;
                    duration: 300
                }
            }
            ParallelAnimation {
                YAnimator {
                    target: imagecenter;
                    from: imageleft.y * 4.8
                    to: imageleft.y
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
            }
        }
        PauseAnimation { duration: 800 }
        running: true
        loops: Animation.Infinite
    }
    SequentialAnimation{
        PauseAnimation { duration: 600 }
        SequentialAnimation{
            ParallelAnimation {
                YAnimator {
                    target: imageright
                    from: imageleft.y
                    to: imageleft.y * 4.8
                    easing.type: Easing.OutExpo;
                    duration: 300
                }
            }
            ParallelAnimation {
                YAnimator {
                    target: imageright;
                    from: imageleft.y * 4.8
                    to: imageleft.y
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
            }
        }
        PauseAnimation { duration: 500 }
        running: true
        loops: Animation.Infinite
    }
    Rectangle {
        id: rectangle

        anchors.horizontalCenter: background.horizontalCenter
        anchors.top: textkun.bottom
        color: "#ffffff"
        anchors.topMargin: 28
        width: textkun.width
        Image {
            id: imageleft
            anchors.right: imagecenter.left
            height: textkun.height / 3
            width:textkun.height / 3
            source: "circle.svg"
            anchors.topMargin: 28
            anchors.rightMargin: 9
            anchors.leftMargin: 16
            y:imagecenter.y

            fillMode: Image.PreserveAspectFit
        }
        Image {
            id: imagecenter
            height: textkun.height / 3
            width:textkun.height / 3
            source: "circle.svg"
            anchors.topMargin: 28
            anchors.leftMargin: 9
            anchors.centerIn: rectangle
            fillMode: Image.PreserveAspectFit
        }
        Image {
            id: imageright
            anchors.left: imagecenter.right
            height: imagecenter.height
            source: "circle.svg"
            y:imagecenter.y
            anchors.topMargin: 28

            anchors.leftMargin: 9
            fillMode: Image.PreserveAspectFit
        }
    }
    }
}
