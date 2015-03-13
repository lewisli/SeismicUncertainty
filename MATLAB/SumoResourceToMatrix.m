function [ Output ] = SumoResourceToMatrix(filename)
%SumoResourceToMatrix Summary of this function goes here
%   Detailed explanation goes here

DOMnode = xmlread(filename);
SumoResource = DOMnode.getDocumentElement;
Resource = SumoResource.getChildNodes;

%
%
%
% % Get the "AddressBook" node
% addressBookNode = docNode.getDocumentElement;
% % Get all the "Entry" nodes
% entries = addressBookNode.getChildNodes;
% % Get the first "Entry"'s children
% % Remember that java arrays are zero-based
% friendlyInfo = entries.item(0).getChildNodes;
% % Iterate over the nodes to find the "PhoneNumber"
% % once there are no more siblinings, "node" will be empty
% node = friendlyInfo.getFirstChild;
% while ~isempty(node)
%     if strcmpi(node.getNodeName, 'PhoneNumber')
%         break;
%     else
%         node = node.getNextSibling;
%     end
% end
% phoneNumber = node.getTextContent
%

Output = 0;

end

