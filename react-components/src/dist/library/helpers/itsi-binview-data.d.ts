declare const itsiMaterials: ({
    category: string;
    className: string;
    children: {
        collections: ({
            id: number;
            teacherGuideUrl: string;
        } | {
            id: number;
            teacherGuideUrl?: undefined;
        })[];
    }[];
    loginRequired?: undefined;
} | {
    category: string;
    loginRequired: boolean;
    className: string;
    children: {
        ownMaterials: boolean;
    }[];
} | {
    category: string;
    loginRequired: boolean;
    className: string;
    children: {
        materialsByAuthor: boolean;
    }[];
})[];
export default itsiMaterials;
