const formatContent = (content, type) => {
    let formatedContent;
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'EventList') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                headerText: content.content.EventStartDate,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp.FileURLDesktop,
                footer: {
                    description: {
                        descPrimary: content.content.Name,
                        descSecondary: content.content.Name,
                    },
                },
            };
        }
        else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                headerText: null,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp.FileURLDesktop,
                footer: {
                    description: {
                        descPrimary: content.content.Name,
                        descSecondary: content.content.Name,
                    },
                },
            };
        }
    }
    return formatedContent;
}

const formatContentCompressed = (content, type) => {
    let formatedContent;
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'EventList') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                headerText: content.content.EventStartDate.slice(0, 10),
                title: content.content.Title,
                imgSrc: temp.FileURLDesktop,
                description: content.content.Name
            };
        }
        else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                headerText: null,
                title: content.content.Title,
                imgSrc: temp.FileURLDesktop,
                description: null
            };
        }
    }
    return formatedContent;
}

export {formatContent, formatContentCompressed};