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
    return roles;
}

QVariant DevicesProxyModel::data(const QModelIndex &index, int role) const
{
    if (role == SectionRole) {
        if (index.data(QBluez::DevicesModel::ConnectedRole).toBool()) {
            return QStringLiteral("Connected");
        } else if (index.data(QBluez::DevicesModel::PairedRole).toBool()) {
            return QStringLiteral("Paired");
        }
        return QStringLiteral("Available");
    }

    return QSortFilterProxyModel::data(index, role);
}

bool DevicesProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    bool leftConnected = left.data(QBluez::DevicesModel::ConnectedRole).toBool();
    bool leftPaired = left.data(QBluez::DevicesModel::PairedRole).toBool();
    const QString leftName = left.data(QBluez::DevicesModel::FriendlyNameRole).toString();

    bool rightConnected = right.data(QBluez::DevicesModel::ConnectedRole).toBool();
    bool rightPaired = right.data(QBluez::DevicesModel::PairedRole).toBool();
    const QString rightName = right.data(QBluez::DevicesModel::FriendlyNameRole).toString();

    if (leftConnected < rightConnected) {
        return true;
    } else if (leftConnected > rightConnected) {
        return false;
    }

    if (leftPaired > rightPaired) {
        return true;
    } else if (leftPaired < rightPaired) {
        return false;
    }

    return QString::localeAwareCompare(leftName, rightName) > 0;
}

