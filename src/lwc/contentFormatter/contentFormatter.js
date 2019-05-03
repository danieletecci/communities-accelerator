const formatContent = (content, type) => {
    let formatedContent;
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'EventList') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                startDate: content.content.EventStartDate,
                endDate: content.content.EventEndDate,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp.FileURLDesktop,
                footer: {
                    description: {
                        descSecondary: content.content.Location
                    },
                },
            };
        }
        else if(type === 'ArticleList') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                date: content.content.PublishStartDate,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp.FileURLDesktop
            };
        } else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                headerText: null,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp.FileURLDesktop
            };
        }
    }
    return formatedContent;
}

const formatContentCompressed = (content, type) => {
    let formatedContent;
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'EventList' || type === 'EventsRelated') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                startDate: content.content.EventStartDate,
                endDate: content.content.EventEndDate,
                title: content.content.Title,
                imgSrc: temp.FileURLDesktop,
                description: content.content.Extract,
                location: content.content.Location
            };
        }
        else if(type === 'ArticleList' || type === 'ArticlesRelated') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                date: content.content.PublishStartDate,
                title: content.content.Title,
                imgSrc: temp.FileURLDesktop,
                description: content.content.Extract
            };
        } else {
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