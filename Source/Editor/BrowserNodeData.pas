{*******************************************************************************
*                            Genesis Device Engine                             *
*                   Copyright © 2007-2015 Luuk van Venrooij                    *
*                        http://www.luukvanvenrooij.nl                         *
********************************************************************************
*                                                                              *
*  This file is part of the Genesis Device Engine.                             *
*                                                                              *
*  The Genesis Device Engine is free software: you can redistribute            *
*  it and/or modify it under the terms of the GNU Lesser General Public        *
*  License as published by the Free Software Foundation, either version 3      *
*  of the License, or any later version.                                       *
*                                                                              *
*  The Genesis Device Engine is distributed in the hope that                   *
*  it will be useful, but WITHOUT ANY WARRANTY; without even the               *
*  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    *
*  See the GNU Lesser General Public License for more details.                 *
*                                                                              *
*  You should have received a copy of the GNU General Public License           *
*  along with Genesis Device.  If not, see <http://www.gnu.org/licenses/>.     *
*                                                                              *
*******************************************************************************}
unit BrowserNodeData;

{$MODE Delphi}

interface

type
  TBrowserNodeType = (NT_MODEL, NT_POINTLIGHT, NT_SPOTLIGHT);

  TBrowserNodeData = class
    NodeType : TBrowserNodeType;
    FileName : string;

    constructor Create(const aNodeType : TBrowserNodeType; const aFileName : String );
  end;

implementation

constructor TBrowserNodeData.Create(const aNodeType : TBrowserNodeType; const aFileName : String );
begin
  NodeType := aNodeType;
  FileName := aFileName;
end;

end.
