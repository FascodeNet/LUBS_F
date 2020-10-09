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

import QtQuick 2.12;
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
            //anchors.horizontalCenter: background.horizontalCenter
            font.pixelSize: 25
            text: "Thank you for installing SereneLinux"
            anchors.top: presentation.top
            anchors.left: presentation.left
            wrapMode: Text.WordWrap
            width: presentation.width
            //horizontalAlignment: Text.Center
        }
    }

    Rectangle {
        id: rectangle

        anchors.horizontalCenter: background.horizontalCenter
        anchors.bottom: presentation.bottom
        color: "#ffffff"
        anchors.bottomMargin: 28
        width: textkun.width
        // center
        Image {
            id: imagecenter
            height: 8//textkun.height / 3
            width:  8//textkun.width / 3
            source: "circle.svg"
            anchors.topMargin: 28
            anchors.leftMargin: 9
            anchors.centerIn: rectangle

            fillMode: Image.PreserveAspectFit
        }
        // left
        Image {
            id: imageleft
            y:imagecenter.y
            height: imagecenter.height
            width:  imagecenter.width
            source: "circle.svg"
            anchors.right      : imagecenter.left
            anchors.topMargin  : 28
            anchors.rightMargin:  9
            anchors.leftMargin : 16

            fillMode: Image.PreserveAspectFit
        }
        // right
        Image {
            id: imageright
            y:imagecenter.y
            height: imagecenter.height
            width:  imagecenter.width
            source: "circle.svg"
            anchors.left      : imagecenter.right
            anchors.topMargin : 28
            anchors.leftMargin:  9

            fillMode: Image.PreserveAspectFit
        }
    }
    /*
     * Animation
     */
    // left
    SequentialAnimation{
        SequentialAnimation{
            ParallelAnimation {
                YAnimator {
                    target: imageleft
                    from: imageleft.y
                    to: imageleft.y * 6
                    easing.type: Easing.OutQuad;
                    duration: 500
                }
            }
            //PauseAnimation { duration: 200 }
            ParallelAnimation {
                YAnimator {
                    target: imageleft;
                    from: imageleft.y * 6
                    to: imageleft.y
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
            }
        }
        PauseAnimation { duration: 900 }
        running: true
        loops: Animation.Infinite
    }
    // center
    SequentialAnimation{
        PauseAnimation { duration: 200 }
        SequentialAnimation{
            ParallelAnimation {
                YAnimator {
                    target: imagecenter
                    from: imagecenter.y
                    to: imagecenter.y * 6
                    easing.type: Easing.OutQuad;
                    duration: 500
                }
            }
            //PauseAnimation { duration: 200 }
            ParallelAnimation {
                YAnimator {
                    target: imagecenter
                    from: imagecenter.y * 6
                    to: imagecenter.y
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
            }
        }
        PauseAnimation { duration: 700 }
        running: true
        loops: Animation.Infinite
    }
    // right
    SequentialAnimation{
        PauseAnimation { duration: 400 }
        SequentialAnimation{
            ParallelAnimation {
                YAnimator {
                    target: imageright
                    from: imageright.y
                    to: imageright.y * 6
                    easing.type: Easing.OutQuad;
                    duration: 500
                }
            }
            //PauseAnimation { duration: 200 }
            ParallelAnimation {
                YAnimator {
                    target: imageright;
                    from: imageright.y * 6
                    to: imageright.y
                    easing.type: Easing.OutBounce;
                    duration: 1000
                }
            }
        }
        PauseAnimation { duration: 500 }
        running: true
        loops: Animation.Infinite
    }
    /**/
}
