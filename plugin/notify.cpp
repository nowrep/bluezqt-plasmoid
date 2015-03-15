/*
    Copyright 2015 David Rosca <nowrep@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "notify.h"

#include <QIcon>

#include <KNotification>
#include <KLocalizedString>

Notify::Notify(QObject *parent)
    : QObject(parent)
{
}

void Notify::connectionFailed(const QString &title, BluezQt::PendingCall *call)
{
    QString text;

    switch (call->error()) {
    case BluezQt::PendingCall::Failed:
        if (call->errorText() == QLatin1String("Host is down")) {
            text = i18nc("Notification when the connection failed due to Failed:HostIsDown",
                         "The device is unreachable");
        } else {
            text = i18nc("Notification when the connection failed due to Failed",
                         "Connection to the device failed");
        }
        break;

    case BluezQt::PendingCall::NotReady:
        text = i18nc("Notification when the connection failed due to NotReady",
                     "The device is not ready");
        break;

    default:
        return;
    }

    KNotification *notification = new KNotification(QStringLiteral("ConnectionFailed"),
                                                    KNotification::CloseOnTimeout, this);
    notification->setComponentName(QStringLiteral("bluedevil"));
    notification->setPixmap(QIcon::fromTheme(QStringLiteral("dialog-warning")).pixmap(64));
    notification->setTitle(title);
    notification->setText(text);
    notification->sendEvent();
}

