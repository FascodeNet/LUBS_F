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

    /*
     * Slide
     */

    function switchSlides(from, to, forward) {

        to.stop_animation()
        from.visible = false

        to.start_animation()
        to.visible = true
        return true
    }

    Timer {
        interval: 20000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }
    // slide1
    Slide {
        id: slide_1
        Image {
            id: image_1
            source: "01_welcome.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width/2
            anchors.bottom: parent.bottom
            anchors.left  : parent.left
            anchors.bottomMargin: 50

        }
        Text {
            id: description_1
            font.pixelSize: 15
            color: "#333333"
            width: parent.width/2
            text: qsTr("Thank you for installing SereneLinux.\nThis slide will show how to use SereneLinux.")
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            anchors.rightMargin: -20
            anchors.bottomMargin: 50
            wrapMode: Text.WordWrap
        }
        Rectangle{
            id:slide_1_rect_1
            width : slide_1.width +100
            height: slide_1.height+100
            color: "#FFFFFFFF"

            SequentialAnimation on color{
                id:slide_1_color_animation
                PauseAnimation { duration:2000 }
                ColorAnimation {
                    to  : "#00FFFFFF"
                    duration: 1000
                }
            }
        }
        Text {
            id: text_1
            font.pixelSize: 25
            font.weight: font.bold
            color: "#333333"
            text: qsTr("<b>Welcome to SereneLinux</b>")
            x: -800
            anchors.top: presentation.top
            anchors.left: presentation.left
            wrapMode: Text.WordWrap
            width: presentation.width
            SequentialAnimation on x {
                id:slide_1_text_1_animation
                PauseAnimation{ duration: 200 }
                XAnimator{
                    from:-800
                    to: 0
                    easing.type: Easing.OutCubic
                    duration: 1500
                }
            }
        }
        function stop_animation(){
            slide_1_color_animation.stop()
            slide_1_rect_1.color="#FFFFFFFF"
            text_1.x=-800
            slide_1_text_1_animation.stop()
        }
        function start_animation(){
            slide_1_color_animation.start()
            slide_1_text_1_animation.start()

        }
    }

    // slide2
    Slide {
        id: slide_2
        Image {
            id: image_2
            source: "02_xfce.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width/2
            anchors.bottom: parent.bottom
            anchors.left  : parent.left
            anchors.bottomMargin: 50

        }
        Text {
            id: description_2
            font.pixelSize: 15
            color: "#333333"
            width: parent.width/2
            text: qsTr("SereneLinux is using Xfce4 Desktop Enviroment.\nXfce4 gives beautiful UI and freedom of customization.")
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            anchors.rightMargin: -20
            anchors.bottomMargin: 50
            wrapMode: Text.WordWrap
        }
        Rectangle{
            id:slide_2_rect
            width : slide_2.width +100
            height: slide_2.height+100
            color: "#FFFFFFFF"

            SequentialAnimation on color{
                id:slide_2_color_anim
                PauseAnimation { duration:2000 }
                ColorAnimation {
                    to  : "#00FFFFFF"
                    duration: 1000
                }
            }
        }
        Text {
            id: text_2
            font.pixelSize: 25
            font.weight: font.bold
            color: "#333333"
            text: qsTr("<b>Beautiful Desktop</b>")
            x: -800
            anchors.top: presentation.top
            anchors.left: presentation.left
            wrapMode: Text.WordWrap
            width: presentation.width
            SequentialAnimation on x {
                id: text_2_animation
                PauseAnimation{ duration: 200 }
                XAnimator{
                    from:-800
                    to: 0
                    easing.type: Easing.OutCubic
                    duration: 1500
                }
            }
        }
        function stop_animation(){
            text_2_animation.stop()
            slide_2_color_anim.stop()
            text_2.x=-800
            slide_2_rect.color="#FFFFFFFF"
        }
        function start_animation(){
            text_2_animation.start()
            slide_2_color_anim.start()
        }
    }

    // slide3
    Slide {
        id: slide_3
        Image {
            id: image_3
            source: "03_software.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width/2
            anchors.bottom: parent.bottom
            anchors.left  : parent.left
            anchors.bottomMargin: 50

        }
        Text {
            id: description_3
            font.pixelSize: 15
            color: "#333333"
            width: parent.width/2
            text: qsTr("SereneLinux incorporate a Chromium as a default browser.\n\nIf you want to use other software, you can install it easy.")
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            anchors.rightMargin: -20
            anchors.bottomMargin: 50
            wrapMode: Text.WordWrap
        }
        Rectangle{
            id:slide_3_rect
            width : presentation.width
            height: slide_3.height
            color: "#FFFFFFFF"

            SequentialAnimation on color{
                id:slide_3_color_anim
                PauseAnimation { duration:2000 }
                ColorAnimation {
                    to  : "#00FFFFFF"
                    duration: 1000
                }
            }
        }
        Text {
            id: text_3
            font.pixelSize: 25
            font.weight: font.bold
            color: "#333333"
            text: qsTr("<b>Useful softwares</b>")
            x: -800
            anchors.top: presentation.top
            anchors.left: presentation.left
            wrapMode: Text.WordWrap
            width: presentation.width
            SequentialAnimation on x {
                id: text_3_animation
                PauseAnimation{ duration: 200 }
                XAnimator{
                    from:-800
                    to: 0
                    easing.type: Easing.OutCubic
                    duration: 1500
                }
            }
        }
        function stop_animation(){
            text_3_animation.stop()
            slide_3_color_anim.stop()
            text_3.x=-800
            slide_3_rect.color="#FFFFFFFF"
        }
        function start_animation(){
            text_3_animation.start()
            slide_3_color_anim.start()
        }
    }

    // slide4
    Slide {
        id: slide_4
        Image {
            id: image_4
            source: "04_office.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width/2
            anchors.bottom: parent.bottom
            anchors.left  : parent.left
            anchors.bottomMargin: 50

        }
        Text {
            id: description_4
            font.pixelSize: 15
            color: "#333333"
            width: parent.width/2
            text: qsTr("Use Google Document to create document and spread sheet.\nGoogle Document save file safely on online, so you don't use local disk space.")
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            anchors.rightMargin: -20
            anchors.bottomMargin: 50
            wrapMode: Text.WordWrap
        }
        Rectangle{
            id:slide_4_rect
            width : slide_4.width +100
            height: slide_4.height+100
            color: "#FFFFFFFF"

            SequentialAnimation on color{
                id:slide_4_color_anim
                PauseAnimation { duration:2000 }
                ColorAnimation {
                    to  : "#00FFFFFF"
                    duration: 1000
                }
            }
        }
        Text {
            id: text_4
            font.pixelSize: 25
            font.weight: font.bold
            color: "#333333"
            text: qsTr("<b>Create and edit document</b>")
            x: -800
            anchors.top: presentation.top
            anchors.left: presentation.left
            wrapMode: Text.WordWrap
            width: presentation.width
            SequentialAnimation on x {
                id: text_4_animation
                PauseAnimation{ duration: 200 }
                XAnimator{
                    from:-800
                    to: 0
                    easing.type: Easing.OutCubic
                    duration: 1500
                }
            }
        }
        function stop_animation(){
            text_4_animation.stop()
            slide_4_color_anim.stop()
            text_4.x=-800
            slide_4_rect.color="#FFFFFFFF"
        }
        function start_animation(){
            text_4_animation.start()
            slide_4_color_anim.start()
        }
    }

    // slide5
    Slide {
        id: slide_5
        Image {
            id: image_5
            source: "05_website.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width/2
            anchors.bottom: parent.bottom
            anchors.left  : parent.left
            anchors.bottomMargin: 50

        }
        Text {
            id: description_5
            font.pixelSize: 15
            color: "#333333"
            width: parent.width/2
            text: qsTr("Installation will be completed soon. I hope SereneLinux brings you a little pleasure.\n\nIf you have any probrem, feel free to send DM on Twitter(@Fascode_SPT) or visit official website.")
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            anchors.rightMargin: -20
            anchors.bottomMargin: 50
            wrapMode: Text.WordWrap
        }
        Rectangle{
            id:slide_5_rect
            width : slide_5.width +100
            height: slide_5.height+100
            color: "#FFFFFFFF"

            SequentialAnimation on color{
                id:slide_5_color_anim
                PauseAnimation { duration:2000 }
                ColorAnimation {
                    to  : "#00FFFFFF"
                    duration: 1000
                }
            }
        }
        Text {
            id: text_5
            font.pixelSize: 25
            font.weight: font.bold
            color: "#333333"
            text: qsTr("<b>Do you need help?</b>")
            x: -800
            anchors.top: presentation.top
            anchors.left: presentation.left
            wrapMode: Text.WordWrap
            width: presentation.width
            SequentialAnimation on x {
                id: text_5_animation
                PauseAnimation{ duration: 200 }
                XAnimator{
                    from:-800
                    to: 0
                    easing.type: Easing.OutCubic
                    duration: 1500
                }
            }
        }
        function stop_animation(){
            text_5_animation.stop()
            slide_5_color_anim.stop()
            text_5.x=-800
            slide_5_rect.color="#FFFFFFFF"
        }
        function start_animation(){
            text_5_animation.start()
            slide_5_color_anim.start()
        }
    }

    // logo
    Image {
        id: logo
        source: "logo-512.png"
        height: 60
        fillMode: Image.PreserveAspectFit
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 100
        anchors.rightMargin: 50
    }
    // install animation
    Rectangle {
        id: rectangle

        anchors.horizontalCenter: presentation.horizontalCenter
        anchors.bottom: presentation.bottom
        color: "#ffffff"
        anchors.bottomMargin: 28
        width: text_1.width
        // center
        Image {
            id: imagecenter
            height: 8//text_1.height / 3
            width:  8//text_1.width / 3
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
