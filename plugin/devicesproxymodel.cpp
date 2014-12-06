/*
    Copyright 2014 David Rosca <nowrep@gmail.com>

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

#include "devicesproxymodel.h"

#include <QBluez/Adapter>

DevicesProxyModel::DevicesProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    sort(0, Qt::DescendingOrder);
}

QHash<int, QByteArray> DevicesProxyModel::roleNames() const
{
    QHash<int, QByteArray> roles = QSortFilterProxyModel::roleNames();
    roles[SectionRole] = QByteArrayLiteral("Section");
    roles[DeviceFullNameRole] = QByteArrayLiteral("DeviceFullName");
    roles[AdapterFullNameRole] = QByteArrayLiteral("AdapterFullName");
    return roles;
}

QVariant DevicesProxyModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case SectionRole:
        if (index.data(QBluez::DevicesModel::ConnectedRole).toBool()) {
            return QStringLiteral("Connected");
        }
        return QStringLiteral("Available");

    case DeviceFullNameRole:
        if (duplicateIndexAddress(index)) {
            const QString name = QSortFilterProxyModel::data(index, QBluez::DevicesModel::FriendlyNameRole).toString();
            const QString ubi = QSortFilterProxyModel::data(index, QBluez::DevicesModel::UbiRole).toString();
            const QString hci = adapterHciString(ubi);

            if (!hci.isEmpty()) {
                return QString(QStringLiteral("%1 - %2")).arg(name, hci);
            }
        }
        return QSortFilterProxyModel::data(index, QBluez::DevicesModel::FriendlyNameRole);

    case AdapterFullNameRole: {
        QBluez::Adapter *adapter = QSortFilterProxyModel::data(index, QBluez::DevicesModel::AdapterRole).value<QBluez::Adapter*>();
        const QString hci = adapterHciString(adapter->ubi());

        if (!hci.isEmpty()) {
            return QString(QStringLiteral("%1 (%2)")).arg(adapter->alias(), hci);
        }
        // fallthrough
    }

    default:
        return QSortFilterProxyModel::data(index, role);
    }
}

bool DevicesProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    bool leftConnected = left.data(QBluez::DevicesModel::ConnectedRole).toBool();
    const QString leftName = left.data(QBluez::DevicesModel::FriendlyNameRole).toString();

    bool rightConnected = right.data(QBluez::DevicesModel::ConnectedRole).toBool();
    const QString rightName = right.data(QBluez::DevicesModel::FriendlyNameRole).toString();

    if (leftConnected < rightConnected) {
        return true;
    } else if (leftConnected > rightConnected) {
        return false;
    }

    return QString::localeAwareCompare(leftName, rightName) > 0;
}

bool DevicesProxyModel::duplicateIndexAddress(const QModelIndex &idx) const
{
    const QModelIndexList list = match(index(0, 0),
                                       QBluez::DevicesModel::AddressRole,
                                       idx.data(QBluez::DevicesModel::AddressRole).toString(),
                                       2,
                                       Qt::MatchExactly);
    return list.size() > 1;
}

// Returns "hciX" part from UBI "/org/bluez/hciX/dev_xx_xx_xx_xx_xx_xx"
QString DevicesProxyModel::adapterHciString(const QString &ubi) const
{
    int startIndex = ubi.indexOf(QLatin1String("/hci")) + 1;

    if (startIndex < 1) {
        return QString();
    }

    int endIndex = ubi.indexOf(QLatin1Char('/'), startIndex);

    if (endIndex == -1) {
        return ubi.mid(startIndex);
    }
    return ubi.mid(startIndex, endIndex - startIndex);
}

