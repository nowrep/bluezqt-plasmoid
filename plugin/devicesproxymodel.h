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

#ifndef DEVICESPROXYMODEL_H
#define DEVICESPROXYMODEL_H

#include <BluezQt/DevicesModel>
#include <QSortFilterProxyModel>

class DevicesProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    enum AdditionalRoles {
        SectionRole = BluezQt::DevicesModel::LastRole + 10,
        DeviceFullNameRole = BluezQt::DevicesModel::LastRole + 11,
        AdapterFullNameRole = BluezQt::DevicesModel::LastRole + 12
    };

    DevicesProxyModel(QObject *parent = 0);

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;

private:
    BluezQt::DevicesModel *devicesModel() const;
    bool duplicateIndexAddress(const QModelIndex &idx) const;
    QString adapterHciString(const QString &ubi) const;
};

#endif // DEVICESPROXYMODEL_H
